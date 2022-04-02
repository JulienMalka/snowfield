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

      services.nginx.virtualHosts."home.luj" = {
        sslCertificate = "/etc/nginx/certs/subdomains/cert.pem";
        sslCertificateKey = "/etc/nginx/certs/subdomains/key.pem";
        forceSSL = true;
        root = "/srv/homer/";
      };


    };
}
