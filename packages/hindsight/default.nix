# Hindsight memory server (hindsight-api, hindsight-worker, hindsight-admin,
# hindsight-local-mcp) for the hermes agent on jacques. Built from the
# `hindsight-api-slim` workspace member, which is where the code and the
# console scripts live; the `hindsight-api` package on PyPI is an empty shell
# that depends on `hindsight-api-slim[all]`.
#
# Extras: `local-ml` (sentence-transformers on CPU torch, the default
# embedder and reranker) and `local-onnx` are in. `embedded-db` (pg0, a
# bundled Postgres) is out, the server points at a real Postgres with
# pgvector. flashrank (an optional reranker) is not in nixpkgs and is only
# imported when selected. mlx extras are darwin-only.
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

let
  toktok-rs = python3Packages.callPackage ./toktok-rs.nix { };
in
python3Packages.buildPythonApplication rec {
  pname = "hindsight";
  version = "0.10.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vectorize-io";
    repo = "hindsight";
    tag = "v${version}";
    hash = "sha256-MnkC4+U6Q5A4uAS3w7Ujr90etj5EHdYUrUKv3fF4IpQ=";
  };
  sourceRoot = "${src.name}/hindsight-api-slim";

  build-system = with python3Packages; [ hatchling ];

  # psycopg2-binary is the wheel-only name of psycopg2. github-copilot-sdk is
  # only imported by the copilot LLM provider and is not in nixpkgs. markitdown
  # is required with extras; nixpkgs' build already carries their deps, but its
  # metadata does not declare them, so the requirement is re-added bare below.
  pythonRemoveDeps = [
    "psycopg2-binary"
    "github-copilot-sdk"
    "markitdown"
  ];

  # Floors raised upstream for CVE fixes or a transitive crash guard; the
  # nixpkgs set is internally consistent. The two caps are wheel-availability
  # ones (greenlet 3.4 on arm64, tokenizers for transformers 5.5) that do not
  # apply to a source build against nixpkgs' transformers 5.17.
  pythonRelaxDeps = [
    "boto3"
    "greenlet"
    "json-repair"
    "regex"
    "tokenizers"
    "opentelemetry-api"
    "opentelemetry-sdk"
    "opentelemetry-instrumentation-fastapi"
    "opentelemetry-exporter-prometheus"
    "opentelemetry-exporter-otlp-proto-http"
    "opentelemetry-semantic-conventions"
  ];

  dependencies =
    with python3Packages;
    [
      aiohttp
      alembic
      anthropic
      asyncpg
      authlib
      boto3
      claude-agent-sdk
      cohere
      croniter
      cryptography
      dateparser
      fastapi
      fastmcp
      filelock
      google-auth
      google-genai
      greenlet
      httpx
      json-repair
      litellm
      markitdown
      numpy
      obstore
      openai
      opentelemetry-api
      opentelemetry-exporter-otlp-proto-http
      opentelemetry-exporter-prometheus
      opentelemetry-instrumentation-fastapi
      opentelemetry-sdk
      opentelemetry-semantic-conventions
      orjson
      pgvector
      pillow
      protobuf
      psycopg2
      pyasn1
      pydantic
      pygments
      pyjwt
      python-dateutil
      python-dotenv
      python-multipart
      regex
      rich
      sqlalchemy
      toktok-rs
      typer
      urllib3
      uvicorn
      uvloop
      wsproto
      # local-ml
      einops
      safetensors
      sentence-transformers
      tokenizers
      torch
      transformers
      # local-onnx
      huggingface-hub
      onnxruntime
    ]
    ++ fastapi.optional-dependencies.standard;

  pythonImportsCheck = [
    "hindsight_api"
    "hindsight_api.engine.embeddings"
    "hindsight_api.engine.cross_encoder"
    "hindsight_api.engine.token_encoding"
  ];

  # The test suite starts Postgres through testcontainers.
  doCheck = false;

  meta = {
    description = "Hindsight agent memory server: retain, recall and reflect over Postgres + pgvector";
    homepage = "https://github.com/vectorize-io/hindsight";
    changelog = "https://github.com/vectorize-io/hindsight/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "hindsight-api";
    platforms = lib.platforms.linux;
  };
}
