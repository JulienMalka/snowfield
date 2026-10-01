{
  lib,
  litellm,
  prisma,
  python,
  prisma_6,
  prisma-engines_6,
  makeWrapper,
  openssl,
}:

let

  prisma-with-litellm-client = prisma.overridePythonAttrs (old: {
    pname = "prisma-with-litellm-client";

    # The installed dist-info is still named "prisma"; the metadata check would
    # look for a distribution matching our renamed pname and fail.
    dontCheckPythonMetadata = true;

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

      export PYTHONPATH=$out/${python.sitePackages}:''${PYTHONPATH:-}
      export PATH=$out/bin:$PATH

      prisma_pkg=$out/${python.sitePackages}/prisma
      cp "$schema_src" "$prisma_pkg/schema.prisma"
      (
        cd "$prisma_pkg"
        ${prisma_6}/bin/prisma generate --schema=schema.prisma
      )
      echo "[prisma-with-litellm-client] generated client for litellm schema (schema at $prisma_pkg/schema.prisma)"

      # prisma-client-py ships its own `prisma` executable, a shim that
      # bootstraps Node through nodeenv and then npm-installs the CLI. Neither
      # works here, and because Python wrappers prepend their dependencies'
      # bin directories to PATH, the shim shadows the real CLI that the
      # litellm wrapper adds below. litellm's startup `prisma db push` then
      # fails on every start, the schema never follows an upgrade, and spend
      # rows are dropped for missing columns. Remove the shim so the only
      # `prisma` on PATH is the nixpkgs CLI.
      rm -f "$out/bin/prisma"
    '';
  });
in
litellm.overridePythonAttrs (old: {
  postPatch = (old.postPatch or "") + ''
        # Raise the free-tier SSO user cap from 5 to 500. The check lives in
        # `_raise_if_sso_exceeds_free_user_limit` in
        # litellm/proxy/management_endpoints/ui_sso.py — an MIT-licensed file
        # (outside the enterprise/ and litellm_enterprise/ trees), so editing
        # it is within MIT rights. We deliberately do NOT force is_premium()
        # True and do NOT touch any enterprise/ code: JWT auth
        # (`enable_jwt_auth`) and header attribution (`user_header_name`) are
        # already MIT, so this one line is the only gate on our SSO flow.
        f=litellm/proxy/management_endpoints/ui_sso.py
        if [ -f "$f" ] && grep -q 'billable_users > 5' "$f"; then
          sed -i 's/billable_users > 5:/billable_users > 500:/' "$f"
          echo "[litellm-patched] SSO free-user cap raised 5->500 in $f"
        else
          echo "[litellm-patched] WARNING: SSO cap pattern not found in $f; upstream may have moved it" >&2
          exit 1
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

  # litellm's proxy runtime deps (websockets, fastapi, fastapi-sso, uvicorn,
  # mcp, pyjwt, prisma, azure-keyvault, ...) live in optional-dependencies, not
  # base `dependencies`. The default (python 3.14) build happened to get them
  # transitively, but the python 3.13 build does not and crash-loops on
  # `ModuleNotFoundError: websockets`. Pull the proxy extras in explicitly so
  # the proxy works regardless of interpreter.
  propagatedBuildInputs =
    map (pkg: if (pkg.pname or "") == "prisma" then prisma-with-litellm-client else pkg)
      (
        (old.propagatedBuildInputs or [ ])
        ++ (old.optional-dependencies.proxy or [ ])
        ++ (old.optional-dependencies.extra_proxy or [ ])
      );

  dependencies =
    map (pkg: if (pkg.pname or "") == "prisma" then prisma-with-litellm-client else pkg)
      (
        (old.dependencies or [ ])
        ++ (old.optional-dependencies.proxy or [ ])
        ++ (old.optional-dependencies.extra_proxy or [ ])
      );

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  postFixup = (old.postFixup or "") + ''
    wrapProgram "$out/bin/litellm" \
      --prefix PATH : ${
        lib.makeBinPath [
          openssl
          # litellm shells out to `prisma db push` at startup to sync the DB
          # schema (see --use_prisma_db_push in machines/gustave/litellm.nix).
          # Without the CLI on PATH that subprocess call raises FileNotFoundError
          # and the schema silently never migrates.
          prisma_6
        ]
      } \
      --set PRISMA_QUERY_ENGINE_BINARY     ${prisma-engines_6}/bin/query-engine \
      --set PRISMA_QUERY_ENGINE_LIBRARY    ${prisma-engines_6}/lib/libquery_engine.node \
      --set PRISMA_SCHEMA_ENGINE_BINARY    ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_MIGRATION_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_INTROSPECTION_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_FMT_BINARY              ${prisma-engines_6}/bin/prisma-fmt
  '';
})
