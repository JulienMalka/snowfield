{ lib, pkgs, inputs, config, ... }:
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

      services.nginx.virtualHosts."luj.home" = {
        sslCertificate = "/etc/nginx/certs/home/cert.pem";
        sslCertificateKey = "/etc/nginx/certs/home/key.pem";
        forceSSL = true;
        root = "/srv/homer/";
      };


    };
}
