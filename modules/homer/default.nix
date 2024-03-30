{ lib, config, ... }:
with lib;
let
  cfg = config.luj.homer;
in
{
  options.luj.homer = {
    enable = mkEnableOption "enable homer";
  };

  config = mkIf cfg.enable
    {
      luj.nginx.enable = true;

      security.acme.certs."home.luj".server = "https://ca.luj/acme/acme/directory";

      services.nginx.virtualHosts."home.luj" = {
        enableACME = true;
        forceSSL = true;
        root = "/srv/homer/";
      };


    };
}
