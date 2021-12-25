{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.drone;
  droneserver = config.users.users.droneserver.name;
  port = 3030;
in
{

  options.luj.drone = {
    enable = mkEnableOption "activate drone CI";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{

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
          User = droneserver;
          Group = droneserver;
        };
      };
      services.postgresql = {
        enable = true;
        ensureDatabases = [ droneserver ];
        ensureUsers = [{
          name = droneserver;
          ensurePermissions = {
            "DATABASE ${droneserver}" = "ALL PRIVILEGES";
          };
        }];
      };
      users.users.droneserver = {
        isSystemUser = true;
        createHome = true;
        group = droneserver;
      };
      users.groups.droneserver = { };

      #environment.etc.drone-runner-exec = {
      #  target = "drone-runner-exec/config";
      #  text = ''
      #    DRONE_RPC_PROTO=https
      #    DRONE_RPC_HOST=${cfg.nginx.subdomain}.julienmalka.me
      #    DRONE_RPC_SECRET=JIJ1pfTgJldCMAgKtGLOnbQE5e8oUPSo2DqlWayVLQFVXDe3898DYvixRiprddY1M
      #    DRONE_UI_USERNAME=root
      #    DRONE_UI_PASSWORD=root
      #  '';
      #};

      systemd.services.drone-runner-exec = {
        description = "Drone Exec Runner";
        startLimitIntervalSec = 5;
        serviceConfig = {
          EnvironmentFile = [ config.sops.secrets.drone.path ];
          Environment = [
            "DRONE_SERVER_HOST=${cfg.nginx.subdomain}.julienmalka.me"
            "DRONE_SERVER_PROTO=https"
            "CLIENT_DRONE_RPC_HOST=127.0.0.1:3030"
          ];

          ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec service run";
        };
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.git pkgs.docker pkgs.docker-compose ];
      };

    }

      (mkIf cfg.nginx.enable {
        luj.nginx.enable = true;
        services.nginx.virtualHosts."${cfg.nginx.subdomain}.julienmalka.me" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString port}";
          };
        };

      })]);


}
