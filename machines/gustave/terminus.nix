{
  config,
  pkgs,
  ...
}:

let
  inherit (pkgs) terminus;
  port = 2300;
  domain = "trmnl.luj.fr";
  apiUri = "https://${domain}";
  redisSocket = "/run/redis-terminus/redis.sock";
  envFile = config.age.secrets."terminus-env".path;

  prepareRuntime = pkgs.writeShellScript "terminus-prepare-runtime" ''
    set -eu
    APP_DIR=/run/terminus/app
    PKG_DIR=${terminus}/share/terminus
    STATE=/var/lib/terminus

    mkdir -p "$APP_DIR/public"

    for entry in "$PKG_DIR"/*; do
      name=$(basename "$entry")
      case "$name" in
        public) ;;
        *) ln -sfn "$entry" "$APP_DIR/$name" ;;
      esac
    done

    for entry in "$PKG_DIR"/public/*; do
      name=$(basename "$entry")
      case "$name" in
        uploads) ;;
        *) ln -sfn "$entry" "$APP_DIR/public/$name" ;;
      esac
    done

    ln -sfn "$STATE/uploads" "$APP_DIR/public/uploads"
    ln -sfn "$STATE/tmp"     "$APP_DIR/tmp"
    ln -sfn "$STATE/log"     "$APP_DIR/log"
  '';

  commonEnv = {
    HANAMI_ENV = "production";
    HANAMI_PORT = toString port;
    API_URI = apiUri;
    DATABASE_URL = "postgres:///terminus?host=/run/postgresql";
    KEYVALUE_URL = "unix://${redisSocket}?db=0";
    PIDFILE = "/run/terminus-web/server.pid";
  };

  commonService = {
    User = "terminus";
    Group = "terminus";
    EnvironmentFile = envFile;
    WorkingDirectory = "/run/terminus";
    StateDirectory = "terminus";
    StateDirectoryMode = "0750";
    RuntimeDirectory = "terminus";
    RuntimeDirectoryMode = "0750";
    ExecStartPre = [ prepareRuntime ];
    Restart = "on-failure";
    RestartSec = 5;

    ProtectHome = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ReadWritePaths = [ "/run/postgresql" ];
  };

  webStart = pkgs.writeShellScript "terminus-web-start" ''
    cd /run/terminus/app
    exec ${terminus}/bin/terminus-puma --config /run/terminus/app/config/puma.rb
  '';

  workerStart = pkgs.writeShellScript "terminus-worker-start" ''
    cd /run/terminus/app
    exec ${terminus}/bin/terminus-sidekiq -r /run/terminus/app/config/sidekiq.rb
  '';

  webMigrate = pkgs.writeShellScript "terminus-web-migrate" ''
    cd /run/terminus/app
    # --no-dump skips the post-migration `db structure dump`, which tries
    # to write `config/db/structure.sql` — read-only under /nix/store.
    # The structure.sql in the package is only useful as a dev artefact.
    exec ${terminus}/bin/terminus-hanami db migrate --no-dump
  '';
in
{
  age.secrets."terminus-env" = {
    file = ./terminus-env.age;
    owner = "terminus";
  };

  users.users.terminus = {
    isSystemUser = true;
    group = "terminus";
    home = "/var/lib/terminus";
  };
  users.groups.terminus = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/terminus           0750 terminus terminus - -"
    "d /var/lib/terminus/uploads   0755 terminus terminus - -"
    "d /var/lib/terminus/tmp       0750 terminus terminus - -"
    "d /var/lib/terminus/log       0750 terminus terminus - -"
  ];

  services.postgresql = {
    ensureDatabases = [ "terminus" ];
    ensureUsers = [
      {
        name = "terminus";
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.servers.terminus = {
    enable = true;
    port = 0;
    unixSocket = redisSocket;
    unixSocketPerm = 660;
    user = "terminus";
  };
  users.users.terminus.extraGroups = [ "redis-terminus" ];

  systemd.services.terminus-web = {
    description = "Terminus web server (Puma)";
    after = [
      "network.target"
      "postgresql.service"
      "redis-terminus.service"
    ];
    wants = [
      "postgresql.service"
      "redis-terminus.service"
    ];
    wantedBy = [ "multi-user.target" ];

    environment = commonEnv;

    serviceConfig = commonService // {
      RuntimeDirectory = [
        "terminus"
        "terminus-web"
      ];
      ExecStartPre = [
        prepareRuntime
        webMigrate
      ];
      ExecStart = webStart;
    };
  };

  systemd.services.terminus-worker = {
    description = "Terminus background worker (Sidekiq)";
    after = [
      "network.target"
      "terminus-web.service"
    ];
    wants = [
      "postgresql.service"
      "redis-terminus.service"
    ];
    wantedBy = [ "multi-user.target" ];

    environment = commonEnv;

    serviceConfig = commonService // {
      ExecStart = workerStart;
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/assets/" = {
      alias = "${terminus}/share/terminus/public/assets/";
      extraConfig = ''
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
      '';
    };
    locations."/fonts/".alias = "${terminus}/share/terminus/public/fonts/";
    locations."/icons/".alias = "${terminus}/share/terminus/public/icons/";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        client_max_body_size 25m;
        proxy_read_timeout 5m;
      '';
    };
  };
}
