{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.jackett;
  port = 9117;
in
{

  options.luj.jackett = {
    enable = mkEnableOption "activate jackett service";

    user = mkOption {
      type = types.str;
      default = "jackett";
      description = "User account under which Jackett runs.";
    };

    group = mkOption {
      type = types.str;
      default = "jackett";
      description = "Group under which Jackett runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.jackett = {
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
