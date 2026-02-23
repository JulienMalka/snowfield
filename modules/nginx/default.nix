systemArgs@{ lib, config, ... }:
with lib;
let
  cfg = config.luj.nginx;
  mergeSub =
    f:
    lib.mkMerge (
      map (sub: f (sub.systemConfig systemArgs)) (lib.attrValues config.services.nginx.virtualHosts)
    );

  recordsFromDomain =
    domain:
    mapAttrs' (
      n: v:
      nameValuePair (dns.domainToZone dns.allowedDomains n) (
        let
          subdomain = dns.getDomainPrefix dns.allowedDomains n;
        in
        if elem subdomain dns.allowedDomains then v else { subdomains."${subdomain}" = v; }
      )
    ) (dns.domainToRecords domain config.machine.meta (dns.isVPNDomain domain));

in
{

  options = {
    luj.nginx = {
      enable = mkEnableOption "activate nginx service";
      email = mkOption {
        type = types.str;
        default = "acme@malka.sh";
      };
    };

    # Awesome NixOS crimes
    services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          {
            name,
            ...
          }:
          {
            options = {
              systemConfig = lib.mkOption {
                internal = true;
                type = types.unspecified; # A function from module arguments to config.
              };
            };
            config = {
              locations."/".extraConfig = lib.mkIf (lib.hasSuffix "luj" name) ''
                allow 100.100.45.0/24;
                allow fd7a:115c:a1e0::/48;
                deny all;
              '';

              extraConfig = lib.mkIf (lib.hasSuffix "luj" name) ''
                ssl_stapling off;
              '';

              systemConfig = _: {
                machine.meta.probes.monitors = lib.mkIf (name != "default") {
                  "${name} - IPv4" = {
                    url = "https://${
                      if (hasSuffix "luj" name) then
                        config.machine.meta.ips.vpn.ipv4
                      else
                        config.machine.meta.ips.public.ipv4
                    }";
                    type = "http";
                    accepted_statuscodes = [ "200-299" ];
                    notificationIDList = [ 1 ];
                    headers = ''
                      {
                        "Host": "${name}"
                      }
                    '';
                  };
                  "${name} - IPv6" =
                    lib.mkIf
                      (
                        if (hasSuffix "luj" name) then
                          (config.machine.meta.ips.vpn ? ipv6)
                        else
                          (config.machine.meta.ips.public ? ipv6)
                      )
                      {
                        url = "https://[${
                          if (hasSuffix "luj" name) then
                            config.machine.meta.ips.vpn.ipv6
                          else
                            config.machine.meta.ips.public.ipv6
                        }]";
                        type = "http";
                        accepted_statuscodes = [ "200-299" ];
                        notificationIDList = [ 1 ];
                        headers = ''
                          {
                            "Host": "${name}"
                          }
                        '';
                      };
                };
                security.acme.certs = lib.optionalAttrs (hasSuffix "luj" name) {
                  "${name}".server = lib.mkIf (hasSuffix "luj" name) "https://ca.luj/acme/acme/directory";
                };

                machine.meta.zones = lib.optionalAttrs (name != "default") (recordsFromDomain name);

              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    users.groups.nginx = {
      name = "nginx";
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
        server_names_hash_bucket_size 128;
      '';
      virtualHosts.default = {
        default = true;
        addSSL = true;
        enableACME = false;
        sslCertificate = "/var/lib/acme/default/cert.pem";
        sslCertificateKey = "/var/lib/acme/default/key.pem";
        extraConfig = ''
          ssl_stapling off;
          return 444;
        '';
      };
    };

    security.acme.certs = mergeSub (c: c.security.acme.certs);
    security.acme.defaults.email = "${cfg.email}";
    security.acme.acceptTerms = true;

    age.secrets.nginx-cert = {
      file = ./404-ssl-certificate-cert.age;
      path = "/var/lib/acme/default/cert.pem";
      owner = "acme";
      group = "nginx";
      mode = "0640";
      symlink = false;
    };

    age.secrets.nginx-key = {
      file = ./404-ssl-certificate-key.age;
      path = "/var/lib/acme/default/key.pem";
      owner = "acme";
      group = "nginx";
      mode = "0640";
      symlink = false;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/acme/default 0750 acme nginx - -"
    ];

    machine = mergeSub (c: c.machine);

  };
}
