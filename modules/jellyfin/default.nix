{ lib, pkgs, config, ... }:
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
