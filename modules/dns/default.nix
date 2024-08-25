{
  lib,
  config,
  dnsLib,
  ...
}:
let
  cfg = config.machine.meta;
  allowedDomains = [
    "luj.fr"
    "julienmalka.me"
    "malka.family"
    "luj"
    "luj-static.page"
  ];

  isVPNDomain = domain: lib.dns.domainToZone [ "luj" ] domain != null;
  SOA = {
    nameServer = "ns";
    adminEmail = "dns@malka.sh";
    serial = 0;
  };
  NS = [
    "ns1"
    "ns2"
  ];

  # Set some defaults for a zone
  getSubmodulesCustom =
    inputs@{ name, ... }:
    lib.recursiveUpdate ((lib.head dnsLib.types.zone.getSubModules) ({ inherit name; } // inputs)) {
      config = {
        SOA = lib.mkDefault SOA;
        NS = lib.mkDefault NS;
        subdomains = {
          ns1 = lib.mkDefault {
            A = [ lib.snowfield.router.ips.public.ipv4 ];
            AAAA = [ lib.snowfield.router.ips.public.ipv6 ];
          };
          ns2 = lib.mkDefault {
            A = [ lib.snowfield.akhaten.ips.public.ipv4 ];
            AAAA = [ lib.snowfield.akhaten.ips.public.ipv6 ];
          };
        };
      };
    };

in
with lib;
{
  options = {
    machine.meta.zones = mkOption {
      type = types.attrsOf (
        recursiveUpdate dnsLib.types.zone { getSubModules = [ getSubmodulesCustom ]; }
      );
      default = { };
    };
  };

  config =
    let
      # list of domains that are defined in the current configuration through virtualHosts
      domains = dns.domainsFromConfiguration allowedDomains config;
      # AttrSet domain -> { records }
      recordsPerDomain = map (
        domain:
        mapAttrs' (
          n: v:
          nameValuePair (dns.domainToZone allowedDomains n) (
            let
              subdomain = dns.getDomainPrefix allowedDomains n;
            in
            if elem subdomain allowedDomains then v else { subdomains."${subdomain}" = v; }
          )
        ) (dns.domainToRecords domain cfg (isVPNDomain domain))
      ) domains;
    in

    {
      machine.meta.zones = mkMerge recordsPerDomain;
    };

}
