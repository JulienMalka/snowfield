{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.linkal;
  port = 4145;
in
{

  options.luj.linkal = {
    enable = mkEnableOption "activate linkal service";
  };

  config = mkIf cfg.enable {

    systemd.services.linkal = {
      description = "linkal";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = "${pkgs.linkal}/bin/linkal --calendar-file ${./calendars.json}";
    };


    luj.nginx.enable = true;
    services.nginx.virtualHosts."calendar.ens.malka.sh" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };

  };
}
