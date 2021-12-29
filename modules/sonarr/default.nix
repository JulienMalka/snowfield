{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.sonarr;
  port = 8989;
in
{

  options.luj.sonarr = {

    enable = mkEnableOption "activate sonarr service";

    user = mkOption {
      type = types.str;
      default = "sonarr";
      description = "User account under which Sonarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "sonarr";
      description = "Group under which Sonarr runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.sonarr = {
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
