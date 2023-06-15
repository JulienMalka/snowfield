{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.buildbot;
  port = "1810";
  package = pkgs.buildbot-worker;
  python = package.pythonModule;
  home = "/var/lib/buildbot-worker";
  buildbotDir = "${home}/worker";
in
{

  options.luj.buildbot = {
    enable = mkEnableOption "activate buildbot service";

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable {

    # Buildbot master

    services.buildbot-master = {
      enable = true;
      masterCfg = "${./.}/master.py";
      pythonPackages = ps: [
        ps.requests
        ps.treq
        ps.psycopg2
        pkgs.buildbot-worker
        pkgs.buildbot-plugins.badges
      ];
    };

    systemd.services.buildbot-master = {
      reloadIfChanged = true;
      environment = {
        PORT = port;
        # Github app used for the login button
        GITHUB_OAUTH_ID = "355493f668a8e1aa10cf";
        GITHUB_ORG = "JulienMalka";
        GITHUB_REPO = "nix-config";

        BUILDBOT_URL = "https://ci.julienmalka.me/";
        BUILDBOT_GITHUB_USER = "JulienMalka";
        # comma seperated list of users that are allowed to login to buildbot and do stuff
        GITHUB_ADMINS = "JulienMalka";
      };
      serviceConfig = {
        # Restart buildbot with a delay. This time way we can use buildbot to deploy itself.
        ExecReload = "+${pkgs.systemd}/bin/systemd-run --on-active=60 ${pkgs.systemd}/bin/systemctl restart buildbot-master";
        # in master.py we read secrets from $CREDENTIALS_DIRECTORY
        LoadCredential = [
          "github-token:${config.sops.secrets.github-token.path}"
          "github-webhook-secret:${config.sops.secrets.github-webhook-secret.path}"
          "github-oauth-secret:${config.sops.secrets.github-oauth-secret.path}"
          "buildbot-nix-workers:${config.sops.secrets.buildbot-nix-workers.path}"
        ];
      };
    };
    sops.secrets = {
      github-token = {
        format = "binary";
        sopsFile = ../../secrets/github-token-secret;
      };
      github-webhook-secret = {
        format = "binary";
        sopsFile = ../../secrets/github-webhook-secret;
      };
      github-oauth-secret = {
        format = "binary";
        sopsFile = ../../secrets/github-oauth-secret;
      };
      buildbot-nix-workers = {
        format = "binary";
        sopsFile = ../../secrets/buildbot-nix-workers;
      };
    };

    services.nginx.virtualHosts."ci.julienmalka.me" =
      {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          ssl_session_timeout 1440m;         
          ssl_session_cache shared:SSL:10m;
        '';
        locations."/".proxyPass = "http://127.0.0.1:1810/";
        locations."/sse" = {
          proxyPass = "http://127.0.0.1:1810/sse/";
          # proxy buffering will prevent sse to work
          extraConfig = "proxy_buffering off;";
        };
        locations."/ws" = {
          proxyPass = "http://127.0.0.1:1810/ws";
          proxyWebsockets = true;
          # raise the proxy timeout for the websocket
          extraConfig = "proxy_read_timeout 6000s;";
        };
      };

    #buildbot worker

    nix.settings.allowed-users = [ "buildbot-worker" ];
    users.users.buildbot-worker = {
      description = "Buildbot Worker User.";
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/buildbot-worker";
      group = "buildbot-worker";
      useDefaultShell = true;
    };
    users.groups.buildbot-worker = { };

    systemd.services.buildbot-worker = {
      reloadIfChanged = true;
      description = "Buildbot Worker.";
      after = [ "network.target" "buildbot-master.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.unstable.nix-eval-jobs
        pkgs.git
        pkgs.gh
        pkgs.nix
        pkgs.nix-output-monitor
      ];
      environment.PYTHONPATH = "${python.withPackages (_: [package])}/${python.sitePackages}";
      environment.MASTER_URL = ''tcp:host=localhost:port=9989'';
      environment.BUILDBOT_DIR = buildbotDir;
      environment.WORKER_PASSWORD_FILE = config.sops.secrets.buildbot-nix-worker-password.path;

      serviceConfig = {
        Type = "simple";
        User = "buildbot-worker";
        Group = "buildbot-worker";
        WorkingDirectory = home;

        # Restart buildbot with a delay. This time way we can use buildbot to deploy itself.
        ExecReload = "+${pkgs.systemd}/bin/systemd-run --on-active=60 ${pkgs.systemd}/bin/systemctl restart buildbot-worker";
        ExecStart = "${python.pkgs.twisted}/bin/twistd --nodaemon --pidfile= --logfile - --python ${./worker.py}";
      };
    };
    sops.secrets.buildbot-nix-worker-password = {
      format = "binary";
      owner = "buildbot-worker";
      sopsFile = ../../secrets/buildbot-nix-worker-password;
    };


  };
}

