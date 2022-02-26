{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.jackett;
  port = 28981;
in
{

  options.luj.jackett = {
    enable = mkEnableOption "activate paperless service";

    user = mkOption {
      type = types.str;
      default = "paperless";
      description = "User account under which Paperless runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.paperless-ng = {
        enable = true;
        user = cfg.user;
        mediaDir = "/home/julien/papers";
        extraConfig = {
          PAPERLESS_OCR_LANGUAGE = "fre+eng";
          PAPERLESS_OCR_MODE = "redo";
          PAPERLESS_TIME_ZONE = "Europe/Paris";
        };

      };

    }

      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);




}
