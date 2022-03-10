{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.luj.authelia;
  autheliaConfig = pkgs.writeText "authelia-config.yml"
    (import ./authelia-config.nix { inherit cfg; });
in
{
  options.luj.authelia = {
    enable = mkEnableOption "enable authelia";
  };
  config = mkIf cfg.enable {

    systemd = {
      services.authelia = {


        serviceConfig = {
          User = "authelia";

          StateDirectory = "authelia";
          RuntimeDirectory = "authelia";
          StateDirectoryMode = "0700";
          RuntimeDirectoryMode = "0700";

        };

        script = ''
          exec ${pkgs.authelia}/bin/authelia --config ${autheliaConfig}  
        '';
      };

    };

    users = {
      users.authelia = {
        group = "authelia";
        isSystemUser = true;
      };

      groups.authelia = {
        members = [ "nginx" ];
      };
    };




    services.nginx.virtualHosts."auth.julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = ''
          set $upstream_authelia http://127.0.0.1:9091;
          proxy_pass $upstream_authelia;

          client_body_buffer_size 128k;

          #Timeout if the real server is dead
          proxy_next_upstream error timeout invalid_header http_500 http_502     http_503;

          # Advanced Proxy Config
          send_timeout 5m;
          proxy_read_timeout 360;
          proxy_send_timeout 360;
          proxy_connect_timeout 360;

          # Basic Proxy Config
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 64 256k;

          # If behind reverse proxy, forwards the correct IP
          set_real_ip_from 10.0.0.0/8;
          set_real_ip_from 172.0.0.0/8;
          set_real_ip_from 192.168.0.0/16;
          set_real_ip_from fc00::/7;
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;

        '';
      };
    };

  };
}

