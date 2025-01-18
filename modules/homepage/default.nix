{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.luj.homepage;
in
{
  options.luj.homepage = {
    enable = mkEnableOption "enable homepage";
  };

  config = mkIf cfg.enable {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = ''
          return 301 https://luj.fr$request_uri;
        '';
      };
    };
  };
}
