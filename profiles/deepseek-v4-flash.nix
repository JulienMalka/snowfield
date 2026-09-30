# DeepSeek-V4-Flash-0731 (FP8, ~167 GB) tensor-parallel over two DGX Sparks.
#
# nixpkgs' vLLM (0.24) predates DeepSeek V4, and the model needs the
# community B12X kernels for GB10/SM121 anyway, so this runs eugr's Spark
# image. Flags and environment follow its deepseek-v4-flash-0731 recipe:
# https://github.com/eugr/spark-vllm-docker/blob/main/recipes/deepseek-v4-flash-0731.yaml
#
# Per-node bits (rank, interconnect addresses) live in each machine.
{
  luj.vllm-cluster = {
    enable = true;
    # nightly-20260930; both nodes must run the same digest.
    image = "docker.io/eugr/spark-vllm-b12x@sha256:e241b798741e5a13cea5827d88e2861e08e3033fa75b927553a69aa770e17306";
    model = "deepseek-ai/DeepSeek-V4-Flash-0731";
    servedModelNames = [
      "deepseek-v4-flash"
      "deepseek-ai/DeepSeek-V4-Flash-0731"
    ];
    nodes = 2;
    masterAddr = "192.168.100.11";

    interconnect = {
      primaryInterface = "enp1s0f0np0";
      rdmaDevices = [
        "mlx5_0"
        "mlx5_2"
      ];
    };

    extraArgs = [
      "--trust-remote-code"
      "--kv-cache-dtype"
      "fp8"
      "--block-size"
      "256"
      "--max-model-len"
      "auto"
      "--max-num-seqs"
      "8"
      "--max-num-batched-tokens"
      "8192"
      "--gpu-memory-utilization"
      "0.85"
      "--enable-prefix-caching"
      "--tokenizer-mode"
      "deepseek_v4"
      "--tool-call-parser"
      "deepseek_v4"
      "--enable-auto-tool-choice"
      "--reasoning-parser"
      "deepseek_v4"
      "--reasoning-config"
      ''{"reasoning_parser":"deepseek_v4","reasoning_start_str":"","reasoning_end_str":""}''
      "--default-chat-template-kwargs.thinking=true"
      "--default-chat-template-kwargs.reasoning_effort=high"
      "--load-format"
      "b12x"
      "--moe-backend"
      "b12x"
      "--linear-backend"
      "b12x"
      "--attention-backend"
      "B12X"
      "--max-cudagraph-capture-size"
      "48"
      "--compilation-config"
      ''{"cudagraph_mode":"FULL_AND_PIECEWISE","custom_ops":["all"]}''
      "--speculative-config"
      ''{"method":"dspark","num_speculative_tokens":5,"draft_sample_method":"probabilistic","attention_backend":"B12X"}''
    ];

    environment = {
      CUTE_DSL_ARCH = "sm_121a";
      VLLM_USE_AOT_COMPILE = "1";
      VLLM_USE_BREAKABLE_CUDAGRAPH = "0";
      VLLM_USE_MEGA_AOT_ARTIFACT = "1";
      VLLM_MEMORY_PROFILE_INCLUDE_ATTN = "1";
      VLLM_USE_FLASHINFER_SAMPLER = "1";
      VLLM_USE_B12X_WO_PROJECTION = "1";
      VLLM_USE_B12X_MHC = "1";
      VLLM_USE_B12X_FP8_GEMM = "1";
      VLLM_USE_B12X_MOE = "1";
      VLLM_USE_B12X_SPARSE_INDEXER = "1";
      VLLM_USE_V2_MODEL_RUNNER = "1";
      VLLM_MOE_SKIP_PADDING = "0";
      B12X_MLA_SM120_UNIFIED = "1";
      B12X_MOE_FORCE_A8 = "1";
    };
  };
}
