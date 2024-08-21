{ inputs, config, ... }:
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
      vpn.ipv4 = "100.100.45.33";
    };
  };

  deployment.tags = [ "server" ];
  deployment.targetHost = config.machine.meta.ips.public.ipv4;

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
          DHCP = "ipv4";
        };

        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  system.stateVersion = "24.11";
}
