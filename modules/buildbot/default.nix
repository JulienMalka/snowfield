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
        topic = "nix-ci";
      };
      admins = [
        "JulienMalka"
        "camillemndn"
      ];
      evalWorkerCount = 6; # limit number of concurrent evaluations
    };

    systemd.services.buildbot-worker.path = lib.mkForce [
      pkgs.attic-client
      pkgs.git
      pkgs.openssh
      pkgs.gh
      pkgs.nix
      pkgs.nix-eval-jobs
      pkgs.coreutils
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
    services.buildbot-master = {
      pythonPackages = _: [
        pkgs.buildbot-plugins.badges
        pkgs.buildbot-plugins.www
      ];
      extraConfig = ''
        c["www"].update({"plugins": {"badges": {
          "left_pad"  : 5,
          "left_text": "Build Status",  # text on the left part of the image
          "left_color": "#555",  # color of the left part of the image
          "right_pad" : 5,
          "border_radius" : 5, # Border Radius on flat and plastic badges
          # style of the template availables are "flat", "flat-square", "plastic"
          "template_name": "flat.svg.j2",  # name of the template
          "font_face": "DejaVu Sans",
          "font_size": 11,
          "color_scheme": {  # color to be used for right part of the image
            "exception": "#007ec6", 
            "failure": "#e05d44",    
            "retry": "#007ec6",      
            "running": "#007ec6",   
            "skipped": "a4a61d",   
            "success": "#4c1",      
            "unknown": "#9f9f9f",   
            "warnings": "#dfb317"   
            } 
        }}})
      '';
    };
  };
}
