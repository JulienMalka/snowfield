{ lib, config, ... }:
with lib;
let
  cfg = config.luj.influxdb;
  port = 8086;
in
{

  options.luj.influxdb = {

    enable = mkEnableOption "activate influxdb service";

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.influxdb2.enable = true;
    }

      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))]);

}
