{ config, ... }:
{
  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    networkConfig = {
      DHCP = "ipv4";
      Address = config.machine.meta.ips.public.ipv6;
    };
    linkConfig.RequiredForOnline = "routable";
  };

}
