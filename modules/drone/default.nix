{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.drone;
  drone = config.users.users.drone.name;
  port = 3030;
in
{

  options.luj.drone = {
    enable = mkEnableOption "activate drone CI";
    subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    users.users.drone = {
      isNormalUser = true;
      createHome = true;
      home = "/home/drone";
      extraGroups = [ drone config.users.groups.keys.name ];
      passwordFile = config.sops.secrets.user-julien-password.path;
    };
    users.groups.drone = { };
    luj.hmgr.drone.luj.programs.git.enable = true;
    nix.allowedUsers = [ drone ];

    sops.secrets.drone = { };

    sops.secrets.ssh-drone-pub = {
      owner = drone;
      path = "/home/drone/.ssh/id_ed25519.pub";
      mode = "0644";
      format = "binary";
      sopsFile = ../../secrets/ssh-drone-pub;
    };

    sops.secrets.ssh-drone-priv = {
      owner = drone;
      path = "/home/drone/.ssh/id_ed25519";
      mode = "0600";
      format = "binary";
      sopsFile = ../../secrets/ssh-drone-priv;
    };


    systemd.services.drone-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.drone.path ];
        Environment = [
          "DRONE_SERVER_HOST=${cfg.subdomain}.julienmalka.me"
          "DRONE_SERVER_PROTO=https"
          "DRONE_DATABASE_DATASOURCE=postgres:///drone?host=/run/postgresql"
          "DRONE_DATABASE_DRIVER=postgres"
          "DRONE_SERVER_PORT=:3030"
          "DRONE_USER_CREATE=username:Julien,admin:true"
        ];
        ExecStart = "${pkgs.drone}/bin/drone-server";
        User = drone;
        Group = drone;
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ drone ];
      ensureUsers = [{
        name = drone;
        ensurePermissions = {
          "DATABASE ${drone}" = "ALL PRIVILEGES";
        };
      }];
    };

    systemd.services.drone-runner-exec = {
      description = "Drone Exec Runner";
      startLimitIntervalSec = 5;
      serviceConfig = {
        User = drone;
        Group = drone;
        EnvironmentFile = [ config.sops.secrets.drone.path ];
        Environment = [
          "DRONE_SERVER_HOST=${cfg.subdomain}.julienmalka.me"
          "DRONE_SERVER_PROTO=https"
          "CLIENT_DRONE_RPC_HOST=127.0.0.1:3030"
        ];
        ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec service run";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.nixUnstable pkgs.git pkgs.openssh ];
    };

  } // mkSubdomain cfg.subdomain port;
}
