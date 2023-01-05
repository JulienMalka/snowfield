{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.bruit;
  port = 3500;
in
{

  options.luj.bruit = {

    enable = mkEnableOption "activate bruit monitoring";

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.grafana.enable = true;
      services.grafana.settings.server.http_port = port;
      luj.influxdb.enable = true;
      luj.influxdb.nginx = {
        enable = true;
        subdomain = "influxdb";
      };
    }

      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))]);

}
