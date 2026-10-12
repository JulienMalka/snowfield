{ config, pkgs, ... }:

let
  port = 8097;
  domain = "swarm.luj.fr";
in
{
  # JELLYSWARRM_PASSWORD, the admin login for the management UI at /ui.
  age.secrets.jellyswarrm-env.file = ./jellyswarrm-env.age;

  systemd.services.jellyswarrm = {
    description = "Jellyswarrm, one Jellyfin front for several servers";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      JELLYSWARRM_HOST = "127.0.0.1";
      JELLYSWARRM_PORT = toString port;
      JELLYSWARRM_DATA_DIR = "/var/lib/jellyswarrm";
    };

    serviceConfig = {
      # The proxy parses its environment with "_" as the nesting separator,
      # so multi-word settings (public_address, server_name) cannot come from
      # the environment despite what its docs say. Seed them into the config
      # file it maintains; the admin UI owns them from then on.
      ExecStartPre = pkgs.writeShellScript "jellyswarrm-seed-config" ''
        if [ ! -e /var/lib/jellyswarrm/jellyswarrm.toml ]; then
          umask 077
          printf 'public_address = "https://${domain}"\nserver_name = "Swarm"\n' \
            > /var/lib/jellyswarrm/jellyswarrm.toml
        fi
      '';
      ExecStart = "${pkgs.jellyswarrm}/bin/jellyswarrm-proxy";
      EnvironmentFile = config.age.secrets.jellyswarrm-env.path;
      DynamicUser = true;
      # Holds jellyswarrm.toml (with the session key that encrypts every
      # stored upstream credential) and the sqlite database.
      StateDirectory = "jellyswarrm";
      WorkingDirectory = "/var/lib/jellyswarrm";
      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };

  services.nginx.virtualHosts.${domain}.locations."/" = {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    extraConfig = ''
      # Media is streamed through the proxy: do not spool it on disk.
      proxy_buffering off;
      proxy_read_timeout 1h;
      client_max_body_size 20m;
    '';
  };
}
