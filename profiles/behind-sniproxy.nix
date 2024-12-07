{ config, ... }:

let
  allowedUpstream = "2a01:e0a:de4:a0e1:4bb5:9275:6010:e9b5/128";
in
{
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
      # regular listener with ipv6, for ipv6 clients
      {
        addr = "[::]";
        port = 443;
        ssl = true;
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
  };

  networking.nftables.enable = true;
  # Only requests from the router must be accepted by proxy protocol listeners
  # in order to prevent ip spoofing.
  networking.firewall.extraInputRules = ''
    ip6 saddr ${allowedUpstream} tcp dport 444 accept
  '';

}
