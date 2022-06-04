{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.paperless;
  port = 28981;
in
{

  options.luj.paperless = {
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
      services.paperless = {
        enable = true;
        user = cfg.user;
        mediaDir = "/home/julien/papers";
        extraConfig = {
          PAPERLESS_OCR_LANGUAGE = "fra+eng";
          PAPERLESS_OCR_MODE = "redo";
          PAPERLESS_TIME_ZONE = "Europe/Paris";
        };

      };

    }

      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);




}
