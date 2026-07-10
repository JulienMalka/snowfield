{
  config,
  pkgs,
  ...
}:

let
  configFile = (pkgs.formats.yaml { }).generate "litellm-config.yaml" {
    model_list = [
      {
        model_name = "gpt-oss";
        litellm_params = {
          model = "openrouter/gpt-oss";
          api_base = "http://100.100.45.44:8000/v1";
          api_key = "dummy";
        };
        model_info = {
          input_cost_per_token = 1.0e-7;
          output_cost_per_token = 5.0e-7;
        };
      }
      {
        model_name = "qwen3-coder";
        litellm_params = {
          model = "openrouter/qwen3-coder";
          api_base = "http://100.100.45.44:8000/v1";
          api_key = "dummy";
        };
        model_info = {
          input_cost_per_token = 6.0e-8;
          output_cost_per_token = 2.5e-7;
        };
      }
      {
        model_name = "qwen3-235b";
        litellm_params = {
          model = "openrouter/qwen3-235b";
          api_base = "http://100.100.45.44:8000/v1";
          api_key = "dummy";
        };
        model_info = {
          input_cost_per_token = 2.0e-7;
          output_cost_per_token = 6.0e-7;
        };
      }
      {
        model_name = "qwen36-27b";
        litellm_params = {
          model = "openrouter/qwen36-27b";
          api_base = "http://100.100.45.44:8000/v1";
          api_key = "dummy";
        };
        model_info = {
          input_cost_per_token = 3.2e-7;
          output_cost_per_token = 3.2e-6;
        };
      }
      {
        model_name = "gemma4-31b";
        litellm_params = {
          model = "openrouter/gemma4-31b";
          api_base = "http://100.100.45.44:8001/v1";
          api_key = "dummy";
        };
        model_info = {
          input_cost_per_token = 1.2e-7;
          output_cost_per_token = 3.7e-7;
        };
      }
      {
        model_name = "whisper-large-v3";
        litellm_params = {
          model = "openai/whisper-large-v3";
          api_base = "http://100.100.45.44:8002/v1";
          api_key = "dummy";
        };
        model_info = {
          mode = "audio_transcription";
          input_cost_per_second = 1.0e-4;
        };
      }
    ];

    litellm_settings = {
      scheduler = "priority";
      drop_params = true;
      background_health_checks = true;
      health_check_interval = 60;
      health_check_details = false;
      default_internal_user_params = {
        user_role = "internal_user";
        max_budget = 5.0;
        budget_duration = "30d";
        models = [ "all-proxy-models" ];
      };
    };

    general_settings = {
      database_url = "os.environ/DATABASE_URL";
      master_key = "os.environ/LITELLM_MASTER_KEY";
      background_health_checks = true;
      health_check_interval = 60; # 1 min between background pings
      user_header_name = "X-OpenWebUI-User-Email";
      allow_user_auth = true;
      proxy_base_url = "https://inference.luj.fr";
      ui_access_mode = "all_authenticated_users";
      enable_jwt_auth = true;
      litellm_jwtauth = {
        user_id_jwt_field = "sub";
        user_email_jwt_field = "email";
        user_id_upsert = true;
        sync_user_role_and_teams = true;
        roles_jwt_field = "litellm_role";
      };
    };
  };

in
{
  age.secrets.litellm-env = {
    file = ./litellm-env.age;
    owner = "litellm";
    group = "litellm";
    mode = "0400";
  };

  age.secrets.kanidm-oauth2-litellm = {
    file = ../core-security/kanidm-oauth2-litellm.age;
    owner = "litellm";
    group = "litellm";
    mode = "0400";
  };

  users.users.litellm = {
    isSystemUser = true;
    group = "litellm";
    home = "/var/lib/litellm";
    createHome = true;
  };
  users.groups.litellm = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/litellm 0750 litellm litellm - -"
  ];

  systemd.services.litellm = {
    description = "LiteLLM proxy (patched, unlimited SSO)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];

    environment = {
      GENERIC_USER_ROLE_ATTRIBUTE = "litellm_role";
      JWT_PUBLIC_KEY_URL = "https://auth.luj.fr/oauth2/openid/open-webui/public_key.jwk";
    };

    serviceConfig = {
      User = "litellm";
      Group = "litellm";
      RuntimeDirectory = "litellm";
      RuntimeDirectoryMode = "0700";
      EnvironmentFile = [
        config.age.secrets.litellm-env.path
        "-/run/litellm/oidc.env"
      ];
      ExecStartPre = pkgs.writeShellScript "litellm-oidc-env" ''
        umask 077
        printf 'GENERIC_CLIENT_SECRET=%s\n' \
          "$(cat ${config.age.secrets.kanidm-oauth2-litellm.path})" \
          > /run/litellm/oidc.env
      '';
      ExecStart = "${pkgs.litellm-patched}/bin/litellm --config ${configFile} --port 4000 --host 127.0.0.1";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = "/var/lib/litellm";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/litellm" ];
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "litellm" ];
    ensureUsers = [
      {
        name = "litellm";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.litellm-models-filter = {
    description = "Filter LiteLLM /v1/models down to healthy_endpoints";
    after = [
      "litellm.service"
      "agenix.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "litellm";
      Group = "litellm";
      RuntimeDirectory = "litellm-filter";
      RuntimeDirectoryMode = "0755";
      RuntimeDirectoryPreserve = true;
      ConditionPathExists = "/run/agenix/litellm-env";
      ExecStart = pkgs.writeShellScript "litellm-models-filter" ''
        set -euo pipefail
        KEY=$(${pkgs.gawk}/bin/awk -F= '/^LITELLM_MASTER_KEY=/{sub(/^LITELLM_MASTER_KEY=/,""); print; exit}' /run/agenix/litellm-env)
        if [ -z "$KEY" ]; then
          echo "no master key in env file" >&2
          exit 1
        fi

        HEALTH=$(${pkgs.curl}/bin/curl -sS --max-time 10 \
          -H "Authorization: Bearer $KEY" \
          http://127.0.0.1:4000/health)
        MODELS=$(${pkgs.curl}/bin/curl -sS --max-time 10 \
          -H "Authorization: Bearer $KEY" \
          http://127.0.0.1:4000/v1/models)

        # healthy_endpoints[].model carries provider prefixes
        # (e.g. "openrouter/gpt-oss"); strip everything up to the first
        # "/" so it matches /v1/models[].id (bare "gpt-oss").
        ${pkgs.jq}/bin/jq -n \
          --argjson health "$HEALTH" \
          --argjson models "$MODELS" '
            ($health.healthy_endpoints // [])
              | map(.model | sub("^[^/]+/"; "")) as $healthy
              | $models
              | .data |= map(select(.id as $id | $healthy | index($id)))
          ' > /run/litellm-filter/models.json.tmp
        mv /run/litellm-filter/models.json.tmp /run/litellm-filter/models.json
        chmod 0644 /run/litellm-filter/models.json
      '';
      SuccessExitStatus = [
        0
        1
      ];
    };
  };

  systemd.timers.litellm-models-filter = {
    description = "Refresh filtered /v1/models every 30s";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20s";
      OnUnitActiveSec = "30s";
      Unit = "litellm-models-filter.service";
    };
  };

  services.nginx.virtualHosts."inference.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "= /v1/models" = {
        extraConfig = ''
          default_type application/json;
          add_header Cache-Control "no-store" always;
          try_files /models.json @litellm_passthrough;
          root /run/litellm-filter;
        '';
      };
      "@litellm_passthrough" = {
        proxyPass = "http://127.0.0.1:4000";
      };
      "/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 1h;
          proxy_send_timeout 1h;
          client_max_body_size 100m;
        '';
      };
    };
  };
}
