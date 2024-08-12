{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./stalwart.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips = {
      public.ipv4 = "163.172.91.82";
      vpn.ipv4 = "100.100.45.33";
    };
  };

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

  system.stateVersion = "24.11";
}
