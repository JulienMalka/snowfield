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
        rev = "044c684a47853af53c660e454328348a49277c9c";
        hash = "sha256-FZmz4pSSa+d9UGUZuK6ROktsoDtYL8xBl0eRtr/BAD0=";
      };
      vendorHash = "sha256-Zs900VVd9jZIoeVFv2SqD97hbTqv2JqroDUz8G3XbY0=";
      patches = [
        ./update-lego.patch
      ];
    });

    settings = {
      ACME_ACCEPT_TERMS = "true";
      ACME_EMAIL = "acme@malka.sh";
      DNS_PROVIDER = "gandiv5";
      ENABLE_HTTP_SERVER = "false";
      GITEA_ROOT = "https://git.luj.fr";
      PORT = "8010";
      PAGES_DOMAIN = "luj-static.page";
      RAW_DOMAIN = "raw.luj-static.page";
      PAGES_BRANCHES = "pages,main,master";
      USE_PROXY_PROTOCOL = "true";
    };

    settingsFile = config.age.secrets."pages-settings-file".path;
  };

  networking.firewall.allowedTCPPorts = [
    444
    8010
  ];

  luj.nginx.enable = true;
  services.nginx = {
    appendHttpConfig = ''
      set_real_ip_from 127.0.0.1;
      real_ip_header proxy_protocol;
    '';

    defaultListen = [
      {
        addr = "[::]";
        port = 444;
        ssl = true;
        proxyProtocol = true;
      }
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      {
        addr = config.machine.meta.ips.vpn.ipv4;
        port = 443;
        ssl = true;
      }
      {
        addr = config.machine.meta.ips.vpn.ipv4;
        port = 80;
        ssl = false;
      }
    ];

    streamConfig = ''
      map $ssl_preread_server_name $sni_upstream {
        hostnames;
        default [::]:8010;
      ${lib.concatMapStringsSep "\n" (vhost: "  ${vhost} [::0]:444;") (
        lib.filter (e: e != "default") (lib.attrNames config.services.nginx.virtualHosts)
      )}
      }

      server {
        listen [::]:443;
        ssl_preread on;
        proxy_pass $sni_upstream;
        proxy_protocol on;
      }

    '';

  };

}
