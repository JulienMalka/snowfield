{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.extraConfig = ''
          real_ip_header proxy_protocol;
          set_real_ip_from 127.0.0.1;
        '';
      }
    );
  };

  config = {
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
        patches = [ ./proxy-protocol.patch ];
        vendorHash = "sha256-NHrohvZL7ie29xWpY3bO1BVWrqUywwaKAucZAwvEWto=";
      });

      settings = {
        ACME_ACCEPT_TERMS = "true";
        ACME_EMAIL = "julien@malka.sh";
        DNS_PROVIDER = "gandiv5";
        ENABLE_HTTP_SERVER = "false";
        GITEA_ROOT = "https://git.luj.fr";
        PORT = "8010";
        PAGES_DOMAIN = "luj-static.page";
        RAW_DOMAIN = "raw.luj-static.page";
        PAGES_BRANCHES = "pages,main,master";
        LOG_LEVEL = "trace";
        USE_PROXY_PROTOCOL = "true";
      };

      settingsFile = config.age.secrets."pages-settings-file".path;
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
      8447
    ];

    services.nginx.defaultListen = [
      {
        addr = "127.0.0.1";
        port = 8446;
        ssl = true;
        proxyProtocol = true;
      }
      {
        addr = "0.0.0.0";
        ssl = false;
      }
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
          default 0.0.0.0:8010;
        ${lib.concatMapStringsSep "\n" (vhost: "  ${vhost} 0.0.0.0:8446;") (
          lib.attrNames config.services.nginx.virtualHosts
        )}
        }

        server {
          listen [::]:443;
          ssl_preread on;
          proxy_pass $sni_upstream;
          proxy_protocol on;
        }

        server {
          listen [::]:8447;
          proxy_pass 0.0.0.0:8010;
        }

      '';

      defaultSSLListenPort = 8446;

    };
  };
}
