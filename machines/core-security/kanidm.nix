{ pkgs, config, ... }:
let
  certificate = config.security.acme.certs."auth.luj.fr";
  kanidm = pkgs.kanidm_1_8;
in
{
  services.kanidm = {
    enableServer = true;
    package = kanidm;
    serverSettings = rec {
      domain = "auth.luj.fr";
      origin = "https://${domain}";
      bindaddress = "127.0.0.1:8443";
      trust_x_forward_for = true;
      tls_chain = "${certificate.directory}/fullchain.pem";
      tls_key = "${certificate.directory}/key.pem";
    };
  };

  environment.systemPackages = [ kanidm ];

  users.users.kanidm.extraGroups = [ certificate.group ];

  services.nginx.virtualHosts."auth.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8443";
    };
  };

}
