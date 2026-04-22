systemArgs@{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    mkEnableOption
    optionalAttrs
    types
    ;
  inherit (lib.strings) hasInfix;
  inherit (lib.dns)
    isVPNDomain
    allowedDomains
    domainToZone
    getDomainPrefix
    domainToRecords
    ;

  cfg = config.luj.nginx;

  mergeSub =
    f:
    mkMerge (
      map (sub: f (sub.systemConfig systemArgs)) (lib.attrValues config.services.nginx.virtualHosts)
    );

  recordsFromDomain =
    domain:
    lib.mapAttrs' (
      n: v:
      lib.nameValuePair (domainToZone allowedDomains n) (
        let
          subdomain = getDomainPrefix allowedDomains n;
        in
        if lib.elem subdomain allowedDomains then v else { subdomains."${subdomain}" = v; }
      )
    ) (domainToRecords domain config.machine.meta (isVPNDomain domain));

  # A vhost's name determines whether its probes target the VPN or public IP
  # stack. Build one monitor per address family, emitted via mkIf so IPv6 is
  # silently dropped when the host doesn't advertise an address in that family.
  mkMonitor =
    name: family:
    let
      ips = if isVPNDomain name then config.machine.meta.ips.vpn else config.machine.meta.ips.public;
      bracketed = if family == "ipv6" then "[${ips.${family} or ""}]" else (ips.${family} or "");
    in
    mkIf (ips ? ${family}) {
      url = "https://${bracketed}";
      type = "http";
      accepted_statuscodes = [ "200-299" ];
      notificationIDList = [ 1 ];
      headers = ''
        {
          "Host": "${name}"
        }
      '';
    };

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

    # Extend every virtualHost with a synthetic `systemConfig` field — a function
    # from module args to a partial NixOS config. The nginx module then folds
    # those contributions into `machine.meta.*`, `security.acme.*`, etc. This
    # lets a vhost declared deep in a service module propagate DNS records and
    # monitoring probes without each module knowing about them.
    services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              systemConfig = mkOption {
                internal = true;
                # A function from module arguments to a partial NixOS config.
                type = types.unspecified;
              };
            };
            config = {
              locations."/".extraConfig = mkIf (isVPNDomain name) ''
                allow 100.100.45.0/24;
                allow fd7a:115c:a1e0::/48;
                deny all;
              '';

              extraConfig = mkIf (isVPNDomain name) ''
                ssl_stapling off;
              '';

              systemConfig = _: {
                machine.meta.probes.monitors = mkIf (name != "default") {
                  "${name} - IPv4" = mkMonitor name "ipv4";
                  "${name} - IPv6" = mkMonitor name "ipv6";
                };

                security.acme.certs = optionalAttrs (isVPNDomain name) {
                  ${name}.server = "https://ca.luj/acme/acme/directory";
                };

                machine.meta.zones = optionalAttrs (name != "default") (recordsFromDomain name);
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
    security.acme.defaults.email = cfg.email;
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
