{

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.vllm.instances = {
    gpt-oss = {
      model = "openai/gpt-oss-120b";
      host = "0.0.0.0";
      port = 8000;
      autoStart = true;
      toolCallParser = "openai";
      reasoningParser = "openai_gptoss";
      maxModelLen = 131072;
      extraArgs = [
        "--served-model-name"
        "gpt-oss"
        "openai/gpt-oss-120b"
      ];
    };

    qwen3-coder = {
      model = "Qwen/Qwen3-Coder-30B-A3B-Instruct";
      host = "0.0.0.0";
      port = 8000;
      autoStart = false;
      toolCallParser = "qwen3_coder";
      maxModelLen = 131072;
      extraArgs = [
        "--served-model-name"
        "qwen3-coder"
        "Qwen/Qwen3-Coder-30B-A3B-Instruct"
      ];
    };

    qwen3-235b = {
      model = "Intel/Qwen3-235B-A22B-Instruct-2507-int4-AutoRound";
      host = "0.0.0.0";
      port = 8000;
      autoStart = false;
      toolCallParser = "hermes";
      gpuMemoryUtilization = 0.92;
      maxModelLen = 32768;
    };

    qwen36-27b = {
      model = "Qwen/Qwen3.6-27B-FP8";
      host = "0.0.0.0";
      port = 8000;
      autoStart = false;
      toolCallParser = "hermes";
      reasoningParser = "qwen3";
      enforceEager = false;
      gpuMemoryUtilization = 0.8069;
      maxModelLen = 131072;
      extraArgs = [
        "--served-model-name"
        "qwen36-27b"
        "Qwen/Qwen3.6-27B-FP8"
        "--speculative-config"
        ''{"method":"mtp","num_speculative_tokens":3}''
        "--enable-prefix-caching"
        "--async-scheduling"
        "--max-cudagraph-capture-size"
        "128"
        "--max-num-seqs"
        "8"
        "--max-num-batched-tokens"
        "32768"
      ];
    };

    gemma4-31b = {
      model = "RedHatAI/gemma-4-31B-it-FP8-block";
      host = "0.0.0.0";
      port = 8001;
      autoStart = false;
      toolCallParser = "gemma4";
      reasoningParser = "gemma4";
      enforceEager = false;
      gpuMemoryUtilization = 0.80;
      maxModelLen = 32768;
      extraArgs = [
        "--served-model-name"
        "gemma4-31b"
        "RedHatAI/gemma-4-31B-it-FP8-block"
        "--enable-prefix-caching"
        "--async-scheduling"
        "--max-cudagraph-capture-size"
        "128"
        "--max-num-seqs"
        "8"
        "--max-num-batched-tokens"
        "32768"
      ];
    };
  };

  systemd.services.vllm-qwen36-27b.environment = {
    VLLM_MARLIN_USE_ATOMIC_ADD = "1";
    VLLM_USE_DEEP_GEMM = "0";
    CUDA_MANAGED_FORCE_DEVICE_ALLOC = "1";
    PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
    OMP_NUM_THREADS = "4";
  };
  systemd.services.vllm-gemma4-31b.environment = {
    VLLM_MARLIN_USE_ATOMIC_ADD = "1";
    VLLM_USE_DEEP_GEMM = "0";
    CUDA_MANAGED_FORCE_DEVICE_ALLOC = "1";
    PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
    OMP_NUM_THREADS = "4";
  };
}
