{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.status;
in
{

  options.luj.status = {
    enable = mkEnableOption "activate status page";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{
      systemd = {
        timers.tinystatus = {
          wantedBy = [ "timers.target" ];
          partOf = [ "tinystatus.service" ];
          timerConfig.OnCalendar = "*-*-* *:05,15,25,35,45,55:00";
          timerConfig.Unit = "tinystatus.service";
        };
        services.tinystatus = {
          serviceConfig.Type = "oneshot";
          path = [ pkgs.gawk pkgs.gnused pkgs.curl pkgs.netcat pkgs.unixtools.ping ];
          script = ''
            mkdir -p /var/www/status
            ${pkgs.tinystatus}/bin/tinystatus ${./checks.csv} > /var/www/status/index.html
            ${pkgs.gnused}/bin/sed -i 's/tinystatus/Services status/g' /var/www/status/index.html
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
