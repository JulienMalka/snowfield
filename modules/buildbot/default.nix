{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.luj.buildbot;
in
{

  options.luj.buildbot = {
    enable = mkEnableOption "activate buildbot service";
  };

  config = mkIf cfg.enable {

    services.buildbot-nix.master = {
      enable = true;
      domain = "ci.julienmalka.me";
      workersFile = config.age.secrets.buildbot-nix-workers.path;
      buildSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      github = {
        tokenFile = config.age.secrets.github-token.path;
        webhookSecretFile = config.age.secrets.github-webhook-secret.path;
        oauthSecretFile = config.age.secrets.github-oauth-secret.path;
        oauthId = "bba3e144501aa5b8a5dd";
        user = "JulienMalka";
        admins = [ "JulienMalka" ];
        topic = "nix-ci";
      };
      evalWorkerCount = 10; # limit number of concurrent evaluations
    };

    systemd.services.buildbot-worker.path = lib.mkForce [
      pkgs.attic
      pkgs.git
      pkgs.openssh
      pkgs.gh
      pkgs.nix
      pkgs.nix-eval-jobs
    ];

    services.nginx.virtualHosts."ci.julienmalka.me" = {
      forceSSL = true;
      enableACME = true;
    };

    age.secrets = {
      github-token.file = ../../secrets/github-token-secret.age;
      github-webhook-secret.file = ../../secrets/github-webhook-secret.age;
      github-oauth-secret.file = ../../secrets/github-oauth-secret.age;
      buildbot-nix-workers.file = ../../secrets/buildbot-nix-workers.age;
      buildbot-nix-worker-password = {
        file = ../../secrets/buildbot-nix-worker-password.age;
        owner = "buildbot-worker";
      };
    };

    systemd.services.buildbot-worker.environment.WORKER_COUNT = "14";
    services.buildbot-nix.worker = {
      enable = true;
      workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
    };
  };
}
