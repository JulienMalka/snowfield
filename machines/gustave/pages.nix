{
  lib,
  pkgs,
  config,
  ...
}:
{
  age.secrets."pages-settings-file".file = ../../secrets/pages-settings-file.age;

  services.codeberg-pages = {
    enable = true;
    package = pkgs.unstable.codeberg-pages.overrideAttrs (_: {
      src = pkgs.fetchFromGitea {
        domain = "codeberg.org";
        owner = "Codeberg";
        repo = "pages-server";
        rev = "831ce3d913015e856351dc4d3fc983ada826ef7e";
        hash = "sha256-Ti9sOppHOaUU72A7Bxyfu4phJUed4m/5e9RyjmVino0=";
      };
      patches = [ ../../packages/codeberg-pages-custom/update-lego.patch ];
      vendorHash = "sha256-MWT51u4rjZB/QcJn91CxpCP+/N+O6gbVWAk+PEQlcUA=";
    });

    settings = {
      ACME_ACCEPT_TERMS = "true";
      ACME_EMAIL = "julien@malka.sh";
      DNS_PROVIDER = "gandiv5";
      ENABLE_HTTP_SERVER = "false";
      GITEA_ROOT = "https://git.dgnum.eu";
      PORT = "8010";
      PAGES_DOMAIN = "luj-static.page";
      RAW_DOMAIN = "raw.luj-static.page";
      PAGES_BRANCHES = "pages,main,master";
      USE_PROXY_PROTOCOL = "true";
    };

    settingsFile = config.age.secrets."pages-settings-file".path;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx.defaultListen = [
    {
      addr = "127.0.0.1";
      proxyProtocol = true;
      ssl = true;
    }
    { addr = "127.0.0.2"; }
    {
      addr = "127.0.0.3";
      ssl = false;
    }
    {
      addr = "127.0.0.4";
      ssl = false;
      proxyProtocol = true;
    }
  ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "julien@malka.sh";
  luj.nginx.enable = lib.mkForce false;
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      set_real_ip_from 127.0.0.1;
      real_ip_header proxy_protocol;
    '';
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    streamConfig = ''
      map $ssl_preread_server_name $sni_upstream {
        hostnames;
        default 127.0.0.1:8010;
      ${lib.concatMapStringsSep "\n" (vhost: "  ${vhost} 127.0.0.1:8447;") (
        lib.attrNames config.services.nginx.virtualHosts
      )}
      }

      server {
        listen 127.0.0.1:8447;
        proxy_pass 127.0.0.1:8446;
        proxy_protocol on;
      }

      server {
        listen [::]:443;
        ssl_preread on;
        proxy_pass $sni_upstream;
      }

    '';

    defaultSSLListenPort = 8446;

  };
}
