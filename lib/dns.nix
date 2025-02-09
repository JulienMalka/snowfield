{ lib, dnsLib, ... }:

with lib;

rec {

  allowedDomains = [
    "luj.fr"
    "julienmalka.me"
    "malka.family"
    "luj"
    "malka.sh"
    "hownix.works"
  ];

  isVPNDomain = hasSuffix "luj";

  hasSuffix' = flip strings.hasSuffix;

  domainToZone = allowedDomains: domain: (findFirst (hasSuffix' domain) null allowedDomains);

  filterElligibleDomains = allowedDomains: domain: domainToZone allowedDomains domain != null;

  domainsFromConfiguration =
    allowedDomains: config:
    filter (filterElligibleDomains allowedDomains) (attrNames config.services.nginx.virtualHosts);

  ipsToRecord =
    ipType: ipValue:
    with dnsLib.combinators;
    if ipType == "ipv4" then { A = [ ipValue ]; } else { AAAA = [ ipValue ]; };

  domainToRecords =
    domain: machineMeta: isVPNDomain:
    with dnsLib.combinators;
    (optionalAttrs isVPNDomain (
      mapAttrsWithMerge (n: v: nameValuePair domain (ipsToRecord n v)) machineMeta.ips.vpn
    ))
    // (optionalAttrs (!isVPNDomain) (
      mapAttrsWithMerge (n: v: nameValuePair domain (ipsToRecord n v)) machineMeta.ips.public
    ));

  getDomainPrefix =
    allowedDomains: domain:
    let
      zone = domainToZone allowedDomains domain;
    in
    strings.removeSuffix ".${zone}" domain;

}
