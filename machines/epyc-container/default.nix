{
  inputs,
  profiles,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  boot.isContainer = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ips = {
      public.ipv6 = "2001:bc8:38ee:100:f837:7fff:fe77:7154";
      public.ipv4 = "192.168.0.1";
    };
    profiles = with profiles; [
      server
      vm-simple-network
    ];
  };

  deployment.targetHost = lib.mkForce "2001:bc8:38ee:100:f837:7fff:fe77:7154";

  services.resolved.enable = true;
  networking.useHostResolvConf = false;

  disko = import ./disko.nix;

  system.stateVersion = "25.05";
}
