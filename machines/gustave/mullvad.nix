_:
let
  # Addresses Mullvad assigned to gustave's key (device "Flying Kiwi",
  # public key axigTezuClSoQlxWvpdzXKXUDjrrQlswE50ox0uDLR0=).
  address4 = "10.66.63.50";
  address6 = "fc00:bbbb:bbbb:bb01::3:3f31";

  # The relay: fi-hel-wg-201 (Mullvad-owned, Helsinki), from
  # https://api.mullvad.net/www/relays/wireguard/
  relayPublicKey = "u+Ir9bnz8PtwXoJGQXvCxz6a+1NChEbBIox8KdWarxk=";
  relayEndpoint = "185.65.133.5:51820";

  table = 51820;
in
{
  # The Mullvad tunnel is the egress for deluge (luj.deluge.interface = "wg0")
  # and nothing else. It is not the default route: only packets sourced from
  # the tunnel address, or from a socket bound to wg0, go through it, by way of
  # a dedicated routing table selected by policy rules.
  systemd.network.netdevs."20-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = "1380";
    };
    wireguardConfig.PrivateKeyFile = "/persistent/srv/wg-private";
    wireguardPeers = [
      {
        PublicKey = relayPublicKey;
        AllowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        Endpoint = relayEndpoint;
        PersistentKeepalive = 25;
      }
    ];
  };

  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    address = [
      "${address4}/32"
      "${address6}/128"
    ];
    DHCP = "no";
    networkConfig.IPv6AcceptRA = false;
    routes = [
      {
        Destination = "0.0.0.0/0";
        Table = table;
      }
      {
        Destination = "::/0";
        Table = table;
      }
    ];
    routingPolicyRules = [
      {
        OutgoingInterface = "wg0";
        Table = table;
      }
      {
        From = address4;
        Table = table;
      }
      {
        From = address6;
        Table = table;
      }
    ];
  };
}
