{
  config,
  pkgs,
  lib,
  ...
}:

# WhisperX OpenAI-compatible transcription service. Upstream:
# https://github.com/Nyralei/whisperx-api-server
#
# Provides /v1/audio/transcriptions (and /translations) with the full
# whisper-large-v3 + Silero/pyannote VAD + wav2vec2 alignment +
# pyannote 3.1 diarization pipeline in a single process. Gustave's
# LiteLLM treats it as just another OpenAI-compatible backend.
#
# Bootstrap before first deploy:
#   1. Accept the pyannote 3.1 EULAs on HuggingFace:
#        https://huggingface.co/pyannote/speaker-diarization-3.1
#        https://huggingface.co/pyannote/segmentation-3.0
#   2. Mint a read-only HF token and write the agenix file:
#        printf 'HF_TOKEN=hf_xxx\n' | \
#          ragenix -e machines/inference01/hf-token.age \
#            --editor "cp /dev/stdin"
#   3. Deploy.
#
# Model downloads (~3 GB whisper + ~1 GB pyannote + ~300 MB alignment
# per language) land under /var/lib/whisperx and persist across
# restarts. Configuration uses upstream's pydantic-settings env vars:
# nested fields are joined with `__`.

let
  port = 8002;
in
{
  age.secrets.hf-token = {
    file = ./hf-token.age;
    owner = "whisperx";
    group = "whisperx";
    mode = "0400";
  };

  users.users.whisperx = {
    isSystemUser = true;
    group = "whisperx";
    home = "/var/lib/whisperx";
    createHome = true;
  };
  users.groups.whisperx = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/whisperx 0750 whisperx whisperx - -"
    "d /var/lib/whisperx/huggingface 0750 whisperx whisperx - -"
    "d /var/lib/whisperx/torch 0750 whisperx whisperx - -"
  ];

  systemd.services.whisperx = {
    description = "WhisperX OpenAI-compatible transcription server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      UVICORN_HOST = "0.0.0.0";
      UVICORN_PORT = toString port;
      WHISPER__MODEL = "large-v3";
      WHISPER__COMPUTE_TYPE = "float16";
      WHISPER__INFERENCE_DEVICE = "cuda";
      # Pin model caches under /var/lib/whisperx so first-request
      # downloads survive restarts and don't land in $HOME.
      HF_HOME = "/var/lib/whisperx/huggingface";
      TORCH_HOME = "/var/lib/whisperx/torch";
      # Match the spark-arena recipe used by the FP8 vLLM instances —
      # same allocator behaviour keeps ctranslate2/pyannote working
      # sets contiguous on Blackwell unified memory.
      PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
      # Prometheus exporter wired up so gustave's monitoring profile
      # can scrape /metrics. GPU stats via nvidia-ml-py.
      METRICS__ENABLED = "true";
    };
    serviceConfig = {
      User = "whisperx";
      Group = "whisperx";
      EnvironmentFile = config.age.secrets.hf-token.path;
      ExecStart = "${pkgs.whisperx-api-server}/bin/whisperx-api-server";
      Restart = "on-failure";
      RestartSec = 10;
      WorkingDirectory = "/var/lib/whisperx";
      # First request loads ~5 GB of weights into VRAM and runs the
      # encoder — give it room before systemd kills as unstarted.
      TimeoutStartSec = "300s";
    };
    # WhisperX shares the GPU with the vLLM chat instances. Whisper
    # large-v3 (~3 GB) + pyannote (~1 GB) + alignment (~300 MB)
    # coexists fine with any LLM EXCEPT qwen3-235b (0.92 of the 128 GB
    # unified pool — no margin). Mark that one as conflicting so
    # systemd stops whisperx if 235b starts.
    conflicts = [ "vllm-qwen3-235b.service" ];
  };

  # And the reverse: starting qwen3-235b should stop whisperx.
  # The vLLM module already auto-generates Conflicts= for every
  # services.vllm.instances entry pointing at every OTHER vllm
  # instance — whisperx isn't one, so we wire it in manually.
  systemd.services.vllm-qwen3-235b.conflicts = lib.mkAfter [
    "whisperx.service"
  ];
}
