{ config, pkgs, ... }:
{
  # new-api: OpenAI-compatible gateway in front of the vLLM instances on
  # inference01. Users log in through Kanidm (OIDC), mint their own API
  # tokens, and get per-token usage and quotas. Channels, models, prices
  # and the OIDC client secret are configured in its web UI (stored in the
  # database); the process-level settings live here.

  users.users.new-api = {
    isSystemUser = true;
    group = "new-api";
    home = "/var/lib/new-api";
  };
  users.groups.new-api = { };

  # SESSION_SECRET and CRYPTO_SECRET
  age.secrets.new-api-env = {
    file = ./new-api-env.age;
    owner = "new-api";
    group = "new-api";
  };

  services.postgresql = {
    ensureDatabases = [ "new-api" ];
    ensureUsers = [
      {
        name = "new-api";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.new-api = {
    description = "new-api LLM gateway";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];
    requires = [ "postgresql.service" ];

    environment = {
      PORT = "4000";
      SQL_DSN = "postgres://new-api@/new-api?host=/run/postgresql";
      TZ = "Europe/Paris";
      GIN_MODE = "release";
      MEMORY_CACHE_ENABLED = "true";
      # Behind nginx on the same host.
      TRUSTED_PROXIES = "127.0.0.1";
      SESSION_COOKIE_SECURE = "true";
      SESSION_COOKIE_TRUSTED_URL = "https://inference.luj.fr";
      FRONTEND_BASE_URL = "https://inference.luj.fr";
      # inference01 runs one vLLM instance at a time: test every channel
      # regularly so unavailable models drop out of /v1/models and come
      # back on their own (auto disable/enable is toggled in the UI).
      CHANNEL_TEST_FREQUENCY = "60";
      # Every new (SSO) user gets a first API token automatically.
      GENERATE_DEFAULT_TOKEN = "true";
    };

    serviceConfig = {
      Type = "simple";
      User = "new-api";
      Group = "new-api";
      StateDirectory = "new-api";
      WorkingDirectory = "/var/lib/new-api";
      EnvironmentFile = config.age.secrets.new-api-env.path;
      ExecStart = "${pkgs.new-api}/bin/new-api --log-dir /var/lib/new-api/logs";
      Restart = "on-failure";
      RestartSec = 5;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      ReadWritePaths = [ "/var/lib/new-api" ];
    };
  };

  services.nginx.virtualHosts."inference.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
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
}
