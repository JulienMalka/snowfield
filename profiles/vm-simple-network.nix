{ config, ... }:
{
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = config.machine.meta.defaultInterface;
    networkConfig = {
      DHCP = "ipv4";
      Address = config.machine.meta.ips.public.ipv6;
    };
    linkConfig.RequiredForOnline = "routable";
  };

}
