{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.status;
in
{

  options.luj.jackett = {
    enable = mkEnableOption "activate status page";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{
      systemd = {
        timers.simple-timer = {
          wantedBy = [ "timers.target" ];
          partOf = [ "tinystatus.service" ];
          timerConfig.OnCalendar = "minutely";
        };
        services.tinystatus = {
          serviceConfig.Type = "oneshot";
          script = ''
          mkdir -p /var/www/status
          ${pkgs.tinystatus}/bin/tinystatus ${./checks.csv} > /var/www/status/index.html 
          '';
        };
      };
    }


      (mkIf cfg.nginx.enable {
        luj.nginx.enable = true;
        services.nginx.virtualHosts."${cfg.nginx.subdomain}.julienmalka.me" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/status/";
        };

      })]);




}
