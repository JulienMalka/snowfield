{
  lib,
  pkgs,
  config,
  ...
}:
let
  allowedUpstream = "2a01:e0a:de4:a0e1:4bb5:9275:6010:e9b5/128";
in
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
      GITEA_ROOT = "http://127.0.0.1:3000";
      PORT = "8010";
      PAGES_DOMAIN = "luj-static.page";
      RAW_DOMAIN = "raw.luj-static.page";
      PAGES_BRANCHES = "pages,main,master";
      USE_PROXY_PROTOCOL = "true";
      LOG_LEVEL = "trace";
    };

    settingsFile = config.age.secrets."pages-settings-file".path;
  };

  networking.nftables.enable = true;

  # Only requests from the router must be accepted by proxy protocol listeners
  # in order to prevent ip spoofing.
  networking.firewall.extraInputRules = ''
    ip6 saddr ${allowedUpstream} tcp dport 444 accept
    ip6 saddr ${allowedUpstream} tcp dport 8110 accept
  '';
  networking.firewall.allowedTCPPorts = [
    8010
  ];

  luj.nginx.enable = true;
  services.nginx = {
    appendHttpConfig = ''
      set_real_ip_from ${allowedUpstream};
      real_ip_header proxy_protocol;
    '';

    defaultListen = [
      # proxy protocol listener with ipv6, which is what is used by the sniproxy
      {
        addr = "[::]";
        port = 444;
        ssl = true;
        proxyProtocol = true;
      }
      # used for certificate requests with let's encrypt
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      # listener for ipv6 clients in private infra
      {
        addr = "[${config.machine.meta.ips.vpn.ipv6}]";
        port = 443;
        ssl = true;
      }
      # listener for ipv4 client in private infra
      {
        addr = config.machine.meta.ips.vpn.ipv4;
        port = 443;
        ssl = true;
      }
      # used for certificate request with internal CA
      {
        addr = "[${config.machine.meta.ips.vpn.ipv6}]";
        port = 80;
        ssl = false;
      }
    ];

    # Listen to ipv6 packets coming from the internet, check the SNI
    # If they are one of the declared virtualHosts, forward them to the proxy protocol listener 
    # for that virtualHost, else forward them to the page server
    streamConfig = ''
      map $ssl_preread_server_name $sni_upstream {
        hostnames;
        default [::]:8010;
      ${lib.concatMapStringsSep "\n" (vhost: "  ${vhost} [::0]:444;") (
        lib.filter (e: e != "default") (lib.attrNames config.services.nginx.virtualHosts)
      )}
      }

      server {
        listen [${config.machine.meta.ips.public.ipv6}]:443;
        ssl_preread on;
        proxy_pass $sni_upstream;
        proxy_protocol on;
      }

    '';

  };

}
