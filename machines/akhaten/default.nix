{ inputs, profiles, ... }:
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
    profiles = with profiles; [
      server
      monitoring
    ];
  };

  disko = import ./disko.nix;

  boot.initrd.systemd.enable = true;
  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
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

  #  fileSystems."/srv".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  services.fail2ban.enable = true;

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    config.networkConfig.IPv4Forwarding = true;

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
        routes = [
          {
            Gateway = "163.172.91.1";
            Destination = "0.0.0.0/0";
          }
        ];
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

      "30-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.100.45.1/24"
          "fc00::1/64"
        ];
        networkConfig.IPMasquerade = "ipv4";
      };
    };

    netdevs = {
      "10-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = "/srv/wg-private";
          ListenPort = 51821;
        };
        wireguardPeers = [
          {
            PublicKey = "axigTezuClSoQlxWvpdzXKXUDjrrQlswE50ox0uDLR0=";
            AllowedIPs = [ "10.100.45.2/32" ];
          }
          {
            PublicKey = "ElVrxNiYvV13hEDtqZNw4kLF7UiPTXziz8XgqABB0AU=";
            AllowedIPs = [ "10.100.45.3/32" ];
          }
          {
            PublicKey = "zoDZGWMPZ+QGAh8Ml9OospRJRlaoaWVFpU7EkdJv3XU=";
            AllowedIPs = [ "10.100.45.4/32" ];
          }
        ];
      };
    };

  };

  networking.firewall.allowedUDPPorts = [
    51821
  ];
  networking.firewall.allowedTCPPorts = [
    51821
  ];

  system.stateVersion = "24.11";
}
