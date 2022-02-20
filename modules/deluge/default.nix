{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.deluge;
  port = 8112;
in
{

  options.luj.deluge = {
    enable = mkEnableOption "activate deluge service";

    user = mkOption {
      type = types.str;
      default = "deluge";
      description = "User account under which deluge runs.";
    };

    group = mkOption {
      type = types.str;
      default = "deluge";
      description = "Group under which deluge runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{

      sops.secrets.deluge = {
        owner = cfg.user;
        format = "binary";
        sopsFile = ../../secrets/deluge-login;
      };

      services.deluge = {
        enable = true;
        user = cfg.user;
        group = cfg.group;
        openFirewall = true;
        declarative = true;
        authFile = "/run/secrets/deluge";
        web.enable = true;
        config = {
          download_location = "/home/mediaserver/downloads/complete/";
          allow_remote = true;
        };
        dataDir = "/home/mediaserver/deluge";

      };
    }

      (mkIf cfg.nginx.enable (mkPrivateSubdomain cfg.nginx.subdomain port))]);



}
