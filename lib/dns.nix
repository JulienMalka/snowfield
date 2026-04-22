{ lib, dnsLib, ... }:

let
  inherit (lib)
    filter
    findFirst
    flip
    mapAttrsWithMerge
    nameValuePair
    optionalAttrs
    ;
  inherit (lib.strings) hasSuffix removeSuffix;

  hasSuffix' = flip hasSuffix;
in
rec {
  allowedDomains = [
    "luj.fr"
    "julienmalka.me"
    "malka.family"
    "luj"
    "malka.sh"
    "hownix.works"
    "iljuj.fr"
  ];

  isVPNDomain = hasSuffix ".luj";

  domainToZone = allowedDomains: domain: findFirst (hasSuffix' domain) null allowedDomains;

  filterElligibleDomains = allowedDomains: domain: domainToZone allowedDomains domain != null;

  domainsFromConfiguration =
    allowedDomains: config:
    filter (filterElligibleDomains allowedDomains) (
      builtins.attrNames config.services.nginx.virtualHosts
    );

  ipsToRecord =
    ipType: ipValue: if ipType == "ipv4" then { A = [ ipValue ]; } else { AAAA = [ ipValue ]; };

  domainToRecords =
    domain: machineMeta: vpn:
    optionalAttrs vpn (
      mapAttrsWithMerge (n: v: nameValuePair domain (ipsToRecord n v)) machineMeta.ips.vpn
    )
    // optionalAttrs (!vpn) (
      mapAttrsWithMerge (n: v: nameValuePair domain (ipsToRecord n v)) machineMeta.ips.public
    );

  getDomainPrefix =
    allowedDomains: domain:
    let
      zone = domainToZone allowedDomains domain;
    in
    removeSuffix ".${zone}" domain;
}
