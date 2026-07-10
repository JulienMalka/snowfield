{
  pkgs,
  lib,
  ...
}:

let
  workerCount = 5;

  gustavePgHost = lib.snowfield.gustave.ips.vpn.ipv4;

  workerPath = with pkgs; [
    python312
    git
    gh
    nix
    nixfmt-rfc-style
    nixpkgs-review
    bash
    bubblewrap
  ];

  mkWorker = i: {
    name = "windmill-worker-${toString i}";
    value = {
      description = "Windmill worker ${toString i}";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "network-online.target" ];
      environment = {
        WM_BASE_URL = "https://workflows.luj.fr";
        RUST_LOG = "info";
        MODE = "worker";
        WORKER_GROUP = "default";
        KEEP_JOB_DIR = "false";
        DATABASE_URL = "postgres://windmill@${gustavePgHost}/windmill?sslmode=disable";
      };
      path = workerPath;
      serviceConfig = {
        User = "windmill";
        Group = "windmill";
        ExecStart = lib.getExe pkgs.unstable.windmill;
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "windmill-worker";
      };
    };
  };
in
{
  users.users.windmill = {
    isSystemUser = true;
    group = "windmill";
    home = "/var/lib/windmill-worker";
    createHome = false;
  };
  users.groups.windmill = { };

  nix.settings.allowed-users = [ "windmill" ];
  nix.settings.trusted-users = [ "windmill" ];

  systemd.tmpfiles.rules = [
    "Z /var/lib/windmill-worker - windmill windmill - -"
  ];

  systemd.services = builtins.listToAttrs (map mkWorker (lib.range 1 workerCount));
}
