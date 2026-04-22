{
  pkgs,
  inputs,
  profiles,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./desktop.nix
    ./preservation.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips.vpn.ipv4 = "100.100.45.10";
    profiles = with profiles; [
      preservation
      remote-builders
      syncthing
    ];
    syncthing.id = "PUOXK5U-OR4NX3V-ZDWWZIN-HX3AVPS-VFMPGVC-7BL3R7R-UIDRQVF-4FXEDQP";
  };

  luj.remote-builders.epyc.enable = true;

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;

  disko = import ./disko.nix;

  virtualisation.docker.enable = true;
  services.tailscale.enable = true;
  networking.networkmanager.enable = true;
  services.dbus.enable = true;
  programs.dconf.enable = true;
  programs.fuse.userAllowOther = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
  ];

  system.stateVersion = "25.05";
}
