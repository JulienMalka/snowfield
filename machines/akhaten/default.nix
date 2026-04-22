{ inputs, profiles, ... }:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./network.nix
    ./nsd.nix
    ./stalwart.nix
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
      monitoring
      preservation
      server
    ];
  };

  disko = import ./disko.nix;

  boot.initrd.systemd.enable = true;

  luj.preservation = {
    enable = true;
    earlyBoot = true;
  };

  # /srv holds the WireGuard private key used at stage 1.
  preservation.preserveAt."/persistent".directories = [
    {
      directory = "/srv";
      inInitrd = true;
    }
  ];

  services.fail2ban.enable = true;

  system.stateVersion = "24.11";
}
