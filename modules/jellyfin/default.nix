{ lib, config, ... }:
with lib;
let
  cfg = config.luj.jellyfin;
  port = 8096;
in
{

  options.luj.jellyfin = {

    enable = mkEnableOption "activate jellyfin service";

    user = mkOption {
      type = types.str;
      default = "jellyfin";
      description = "User account under which Jellyfin runs.";
    };

    group = mkOption {
      type = types.str;
      default = "jellyfin";
      description = "Group under which Jellyfin runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.jellyfin = {
        enable = true;
        user = cfg.user;
        group = cfg.group;
      };

      #      services.nginx.appendHttpConfig = ''
      #       server {
      #           server_name tv.julienmalka.me;
      #           listen 80;
      #           return 301 https://$server_name$request_uri;
      #       }

      #      server {
      #          server_name tv.julienmalka.me;
      #          listen 443 ssl http2;

      #         include ${../authelia/authelia.conf}; # Authelia auth endpoint

      #        location / {
      #           proxy_pass http://127.0.0.1:8096;
      #   	    proxy_set_header Host $host;
      # proxy_set_header X-Real-IP $remote_addr;
      # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

      #  	    include ${../authelia/secure.conf}; # Protect this endpoint
      #      }
      #  }
      # '';




      


    }

      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))     
      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);
      
    
      



}
