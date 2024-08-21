{ lib, pkgs, ... }:
{
  services.codeberg-pages = {
    enable = true;
    package = pkgs.codeberg-pages-custom;
    settings = {
      ACME_ACCEPT_TERMS = "true";
      ACME_EMAIL = "julien@malka.sh";
      DNS_PROVIDER = "gandiv5";
      ENABLE_HTTP_SERVER = "false";
      GITEA_ROOT = "https://git.luj.fr";
      PORT = "8010";
      PAGES_DOMAIN = "luj-static.page";
      RAW_DOMAIN = "raw.luj-static.page";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "julien@malka.sh";
  luj.nginx.enable = lib.mkForce false;
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    streamConfig = ''
      map $ssl_preread_server_name $sni_upstream {
        hostnames;
        default 0.0.0.0:8443;
        *.luj-static.page 0.0.0.0:8010;
        luj.sh 0.0.0.0:8010;
      }

      server {
        listen [::]:443;
        ssl_preread on;
        proxy_pass $sni_upstream;
      }

    '';

    defaultSSLListenPort = 8443;

  };

}
