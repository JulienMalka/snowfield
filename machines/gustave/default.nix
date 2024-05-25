{ pkgs, ... }:

{
  imports = [
    ../../users/default.nix
    ../../users/julien.nix
    ./hardware.nix
    ./home-julien.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  disko = import ./disko.nix;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    routes = [
      {
        routeConfig.Metric = 500;
        routeConfig.Destination = "0.0.0.0/0";
      }
    ];
    networkConfig = {
      DHCP = "ipv4";
      Address = "2a01:e0a:de4:a0e1:eb2:aaaa::45/128";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  luj.irc = {
    enable = true;
    nginx = {
      enable = true;
      subdomain = "irc";
    };
  };

  luj.homepage.enable = true;
  luj.mediaserver = {
    enable = true;
    tv.enable = true;
    music.enable = true;
  };
  luj.deluge.interface = "wg0";

  system.stateVersion = "23.11";
}
