{
  config,
  lib,
  pkgs,
  ...
}:
let
  stateDir = "/var/lib/hindsight";
  port = 8888;
  # The only client is Jacques, so the API is bound to the VPN address and
  # the firewall admits that one peer: Hindsight itself has no API auth.
  listen = config.machine.meta.ips.vpn.ipv4;
  jacques = lib.snowfield.jacques.ips.vpn.ipv4;
in
{
  # Long-term memory server for Jacques (machines/jacques/hermes.nix): the
  # hermes plugin retains each turn here and recalls before each one.
  # Extraction runs on the vLLM cluster through litellm next door, the
  # embedder and reranker are small models on this CPU, storage is the
  # local Postgres.

  # HINDSIGHT_API_LLM_API_KEY=<litellm virtual key "hindsight">
  age.secrets.hindsight-env = {
    file = ./hindsight-env.age;
    owner = "hindsight";
    group = "hindsight";
    mode = "0400";
  };

  users.users.hindsight = {
    isSystemUser = true;
    group = "hindsight";
    home = stateDir;
  };
  users.groups.hindsight = { };

  services.postgresql = {
    ensureDatabases = [ "hindsight" ];
    ensureUsers = [
      {
        name = "hindsight";
        ensureDBOwnership = true;
      }
    ];
    extensions = ps: [ ps.pgvector ];
  };

  # The migrations check for pgvector and stop with "CREATE EXTENSION vector"
  # rather than create it, and creating an extension takes the superuser.
  # pg_trgm is optional (entity lookup degrades to exact matching without
  # it) but cheap, so it goes in too.
  systemd.services.hindsight-db-init = {
    description = "Hindsight database extensions";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = pkgs.writeShellScript "hindsight-db-init" ''
        ${config.services.postgresql.package}/bin/psql -d hindsight -v ON_ERROR_STOP=1 \
          -c "CREATE EXTENSION IF NOT EXISTS vector" \
          -c "CREATE EXTENSION IF NOT EXISTS pg_trgm"
      '';
    };
  };

  systemd.services.hindsight = {
    description = "Hindsight memory server for Jacques";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "tailscaled.service"
      "hindsight-db-init.service"
      "litellm.service"
    ];
    wants = [
      "network-online.target"
      "tailscaled.service"
      "litellm.service"
    ];
    requires = [ "hindsight-db-init.service" ];

    restartTriggers = [ config.age.secrets.hindsight-env.file ];

    environment = {
      HINDSIGHT_API_HOST = listen;
      HINDSIGHT_API_PORT = toString port;
      HINDSIGHT_API_DATABASE_URL = "postgresql://hindsight@/hindsight?host=/run/postgresql";
      HINDSIGHT_API_RUN_MIGRATIONS_ON_STARTUP = "true";

      # litellm's only chat model. DeepSeek V4 Flash reasons by default and the
      # thinking is wasted on fact extraction: it took each retain from ~15 s
      # to 50-80 s when measured (2026-10-13). The flag passes through litellm
      # to vLLM; `reasoning_effort` only trims it.
      HINDSIGHT_API_LLM_PROVIDER = "openai";
      HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:4000/v1";
      HINDSIGHT_API_LLM_MODEL = "deepseek-v4-flash";
      HINDSIGHT_API_LLM_EXTRA_BODY = builtins.toJSON { chat_template_kwargs.thinking = false; };
      # Retains and consolidations share the cluster with Jacques' own turns;
      # the default of 32 in flight would let a busy evening crowd those out.
      HINDSIGHT_API_LLM_MAX_CONCURRENT = "4";

      # bge-small (embeddings) and MiniLM (reranker) from the HF hub on first
      # start, cached in the state dir. Both run fine on a few CPU threads.
      HINDSIGHT_API_EMBEDDINGS_PROVIDER = "local";
      HINDSIGHT_API_RERANKER_PROVIDER = "local";
      HF_HOME = "${stateDir}/hf";
      HF_HUB_DISABLE_TELEMETRY = "1";
      OMP_NUM_THREADS = "4";
    };

    serviceConfig = {
      Type = "simple";
      User = "hindsight";
      Group = "hindsight";
      StateDirectory = "hindsight";
      StateDirectoryMode = "0700";
      WorkingDirectory = stateDir;
      EnvironmentFile = config.age.secrets.hindsight-env.path;
      ExecStart = lib.getExe pkgs.hindsight;
      Restart = "on-failure";
      RestartSec = 10;
      ProtectSystem = "strict";
      ReadWritePaths = [ stateDir ];
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  networking.firewall.extraInputRules = ''
    iifname "tailscale0" ip saddr ${jacques} tcp dport ${toString port} accept
  '';
}
