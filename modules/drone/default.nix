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

    users.users.droneserver = {
      isNormalUser = true;
      createHome = true;
      home = "/home/droneserver";
      extraGroups = [ droneserver config.users.groups.keys.name ];
      passwordFile = config.sops.secrets.user-julien-password.path;
    };
    users.groups.droneserver = { };
    luj.hmgr.droneserver.luj.programs.git.enable = true;
    nix.allowedUsers = [ drone ];

    sops.secrets.drone = { };


    systemd.services.drone-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.drone.path ];
        Environment = [
          "DRONE_SERVER_HOST=${cfg.nginx.subdomain}.julienmalka.me"
          "DRONE_SERVER_PROTO=https"
          "DRONE_DATABASE_DATASOURCE=postgres:///droneserver?host=/run/postgresql"
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
          "DRONE_SERVER_HOST=${cfg.nginx.subdomain}.julienmalka.me"
          "DRONE_SERVER_PROTO=https"
          "CLIENT_DRONE_RPC_HOST=127.0.0.1:3030"
        ];
        ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec service run";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.nixUnstable pkgs.git pkgs.openssh ];
    };

    services.nginx.virtualHosts."${cfg.nginx.subdomain}.julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };

    };
  };
}
