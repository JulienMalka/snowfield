# Tests for lib/dns.nix. dnsLib is only needed by the record-building
# helpers, which these tests do not exercise, so a stub stands in for it.
{ lib }:
let
  dns = import ../lib/dns.nix {
    inherit lib;
    dnsLib = { };
  };
in
lib.runTests {
  testVPNDomainBoundaries = {
    expr = map dns.isVPNDomain [
      "luj"
      "host.luj"
      "nested.host.luj"
      "notluj"
      "host.notluj"
      "luj.fr"
      "luj.example.org"
    ];
    expected = [
      true
      true
      true
      false
      false
      false
      false
    ];
  };

  testPublicDomainBoundaries = {
    expr = map (dns.domainToZone [ "julienmalka.me" ]) [
      "julienmalka.me"
      "www.julienmalka.me"
      "fakejulienmalka.me"
      "www.fakejulienmalka.me"
      "julienmalka.me.example.org"
    ];
    expected = [
      "julienmalka.me"
      "julienmalka.me"
      null
      null
      null
    ];
  };

  testZoneOrderIsPreserved = {
    expr = dns.domainToZone [ "example.org" "sub.example.org" ] "host.sub.example.org";
    expected = "example.org";
  };

  testEligibleVirtualHosts = {
    expr = dns.domainsFromConfiguration [ "luj" ] {
      services.nginx.virtualHosts = {
        default = { };
        "host.luj" = { };
        "host.notluj" = { };
      };
    };
    expected = [ "host.luj" ];
  };
}
