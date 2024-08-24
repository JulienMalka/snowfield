{
  lib,
  config,
  inputs,
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
  dnsLib = (import inputs.dns).lib;
  SOA = {
    nameServer = "ns";
    adminEmail = "dns@malka.sh";
    serial = 0;
  };
  NS = [
    "ns1"
    "ns2"
  ];
  defaults = {
    inherit SOA NS;
    subdomains = {
      ns1 = {
        A = [ lib.snowfield.router.ips.public.ipv4 ];
        AAAA = [ lib.snowfield.router.ips.public.ipv6 ];
      };
      ns2 = {
        A = [ lib.snowfield.akhaten.ips.public.ipv4 ];
        AAAA = [ lib.snowfield.akhaten.ips.public.ipv6 ];
      };
    };
  };
in
with lib;
{

  options = {
    machine.meta.zones = mkOption {
      type = types.attrsOf dnsLib.types.zone;
      default = { };
    };
  };

  config =
    let
      # list of domains that are defined in the current configuration throught virtualHosts
      domains = lib.dns.domainsFromConfiguration allowedDomains config;
      # AttrSet domain -> { records }
      recordsPerDomain = map (
        domain:
        mapAttrs' (
          n: v:
          nameValuePair (lib.dns.domainToZone allowedDomains n) (
            let
              subdomain = lib.dns.getDomainPrefix allowedDomains n;
            in
            lib.recursiveUpdate (
              if elem subdomain allowedDomains then v else { subdomains."${subdomain}" = v; }
            ) defaults
          )
        ) (lib.dns.domainToRecords domain cfg (isVPNDomain domain))
      ) domains;
    in

    {
      machine.meta.zones = lib.mkMerge recordsPerDomain;
    };

}
