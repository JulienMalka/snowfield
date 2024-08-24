{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./stalwart.nix
    ./nsd.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips = {
      public.ipv4 = "163.172.91.82";
      public.ipv6 = "2001:0bc8:3d24::45";
      vpn.ipv4 = "100.100.45.33";
    };
  };

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
      "/srv"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  fileSystems."/srv".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  services.fail2ban.enable = true;

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    networks = {
      "10-wan" = {
        matchConfig.Name = "enp0s20";
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = true;
        };
        addresses = [
          { Address = "163.172.91.82/24"; }
          { Address = "2001:0bc8:3d24::45/64"; }
        ];
        gateway = [ "163.172.91.1" ];
        dhcpV6Config = {
          DUIDRawData = "00:01:62:7c:0e:d3:27:5b";
          DUIDType = "link-layer";
          UseAddress = "no";
          WithoutRA = "solicit";
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = "always";
          UseOnLinkPrefix = false;
          UseAutonomousPrefix = false;
        };

        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  system.stateVersion = "24.11";
}
