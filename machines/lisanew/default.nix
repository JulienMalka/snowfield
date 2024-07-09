{ ... }:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  services.fail2ban.enable = true;

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    networks = {
      "10-wan" = {
        matchConfig.Name = "enp0s20";
        networkConfig = {
          DHCP = "ipv4";
        };

        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  system.stateVersion = "24.05";
}
