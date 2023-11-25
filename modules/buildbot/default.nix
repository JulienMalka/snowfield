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
  };

  config = mkIf cfg.enable {

    services.buildbot-nix.master = {
      enable = true;
      domain = "ci.julienmalka.me";
      workersFile = config.sops.secrets.buildbot-nix-workers.path;
      github = {
        tokenFile = config.sops.secrets.github-token.path;
        webhookSecretFile = config.sops.secrets.github-webhook-secret.path;
        oauthSecretFile = config.sops.secrets.github-oauth-secret.path;
        oauthId = "bba3e144501aa5b8a5dd";
        user = "JulienMalka";
        admins = [ "JulienMalka" ];
        topic = "nix-ci";
      };
      evalWorkerCount = 10; # limit number of concurrent evaluations
    };

    services.nginx.virtualHosts."ci.julienmalka.me" = {
      forceSSL = true;
      enableACME = true;
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

    systemd.services.buildbot-worker.environment.WORKER_COUNT = "14";
    services.buildbot-nix.worker = {
      enable = true;
      workerPasswordFile = config.sops.secrets.buildbot-nix-worker-password.path;
    };

    sops.secrets.buildbot-nix-worker-password = {
      format = "binary";
      owner = "buildbot-worker";
      sopsFile = ../../secrets/buildbot-nix-worker-password;
    };

  };
}

