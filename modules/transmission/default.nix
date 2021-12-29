{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.transmission;
  port = 9091;
in
{

  options.luj.transmission = {
    enable = mkEnableOption "activate transmission service";

    user = mkOption {
      type = types.str;
      default = "transmission";
      description = "User account under which transmission runs.";
    };

    group = mkOption {
      type = types.str;
      default = "transmission";
      description = "Group under which Transmission runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{

      sops.secrets.transmission = {
        owner = cfg.user;
        format = "binary";
        sopsFile = ../../secrets/transmission-login;
      };

      services.transmission = {
        enable = true;
        user = cfg.user;
        group = cfg.group;
        credentialsFile = "/run/secrets/transmission";
        downloadDirPermissions = "770";
        settings = {
          rpc-port = 9091;
          download-dir = "/home/mediaserver/downloads/complete/";
          incomplete-dir = "/home/mediaserver/downloads/incomplete/";
          incomplete-dir-enable = true;
        };
      };
    }

      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port) )]);




}
