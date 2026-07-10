{
  lib,
  litellm,
  python3Packages,
  prisma_6,
  prisma-engines_6,
  makeWrapper,
  openssl,
}:

let

  prisma-with-litellm-client = python3Packages.prisma.overridePythonAttrs (old: {
    pname = "prisma-with-litellm-client";

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prisma_6 ];

    env = (old.env or { }) // {
      PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines_6}/lib/libquery_engine.node";
      PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines_6}/bin/schema-engine";
      PRISMA_PY_DEBUG_GENERATOR = "1";
    };

    postInstall = (old.postInstall or "") + ''
      schema_src=${litellm.src}/litellm/proxy/schema.prisma
      if [ ! -f "$schema_src" ]; then
        echo "[prisma-with-litellm-client] schema.prisma not found at $schema_src" >&2
        exit 1
      fi

      export PYTHONPATH=$out/${python3Packages.python.sitePackages}:''${PYTHONPATH:-}
      export PATH=$out/bin:$PATH

      prisma_pkg=$out/${python3Packages.python.sitePackages}/prisma
      cp "$schema_src" "$prisma_pkg/schema.prisma"
      (
        cd "$prisma_pkg"
        ${prisma_6}/bin/prisma generate --schema=schema.prisma
      )
      echo "[prisma-with-litellm-client] generated client for litellm schema (schema at $prisma_pkg/schema.prisma)"
    '';
  });
in
litellm.overridePythonAttrs (old: {
  postPatch = (old.postPatch or "") + ''
        f=litellm/proxy/auth/litellm_license.py
        if [ -f "$f" ]; then
          sed -i 's/def is_premium(self) -> bool:/def is_premium(self) -> bool: return True\n    def _orig_is_premium(self) -> bool:/' "$f"
          echo "[litellm-patched] is_premium() force-returned True in $f"
        else
          echo "[litellm-patched] WARNING: $f not found; premium check NOT neutralized" >&2
        fi

        g=litellm_enterprise/proxy/auth/custom_sso_handler.py
        if [ -f "$g" ]; then
          sed -i 's/raise ValueError(/_neutered_litellm_cap_=ValueError(/g' "$g"
          echo "[litellm-patched] SSO user-cap raise neutralized in $g"
        fi

        h=litellm/llms/hosted_vllm/chat/transformation.py
        if [ -f "$h" ]; then
          cat >> "$h" <<'PYEOF'


    from litellm.llms.base_llm.base_model_iterator import (
        BaseModelResponseIterator as _SnowfieldBaseIter,
    )
    from litellm.types.utils import ModelResponseStream as _SnowfieldMRS


    class _SnowfieldHostedVLLMReasoningStreamingHandler(_SnowfieldBaseIter):
        def chunk_parser(self, chunk: dict) -> _SnowfieldMRS:
            new_choices = []
            for choice in chunk.get("choices", []) or []:
                delta = choice.get("delta") or {}
                if "reasoning" in delta and delta.get("reasoning_content") is None:
                    delta["reasoning_content"] = delta.get("reasoning")
                choice["delta"] = delta
                new_choices.append(choice)
            return _SnowfieldMRS(
                id=chunk.get("id"),
                object="chat.completion.chunk",
                created=chunk.get("created"),
                usage=chunk.get("usage"),
                model=chunk.get("model"),
                choices=new_choices,
            )


    def _snowfield_get_model_response_iterator(
        self, streaming_response, sync_stream, json_mode=False
    ):
        return _SnowfieldHostedVLLMReasoningStreamingHandler(
            streaming_response=streaming_response,
            sync_stream=sync_stream,
            json_mode=json_mode,
        )


    HostedVLLMChatConfig.get_model_response_iterator = (
        _snowfield_get_model_response_iterator
    )
    PYEOF
          echo "[litellm-patched] hosted_vllm streaming reasoning_content remap appended to $h"
        else
          echo "[litellm-patched] WARNING: $h not found; vLLM reasoning trace will be dropped on streaming" >&2
        fi
  '';

  propagatedBuildInputs = map (
    pkg: if (pkg.pname or "") == "prisma" then prisma-with-litellm-client else pkg
  ) (old.propagatedBuildInputs or [ ]);

  dependencies = map (
    pkg: if (pkg.pname or "") == "prisma" then prisma-with-litellm-client else pkg
  ) (old.dependencies or [ ]);

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  postFixup = (old.postFixup or "") + ''
    wrapProgram "$out/bin/litellm" \
      --prefix PATH : ${lib.makeBinPath [ openssl ]} \
      --set PRISMA_QUERY_ENGINE_BINARY     ${prisma-engines_6}/bin/query-engine \
      --set PRISMA_QUERY_ENGINE_LIBRARY    ${prisma-engines_6}/lib/libquery_engine.node \
      --set PRISMA_SCHEMA_ENGINE_BINARY    ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_MIGRATION_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_INTROSPECTION_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_FMT_BINARY              ${prisma-engines_6}/bin/prisma-fmt
  '';
})
