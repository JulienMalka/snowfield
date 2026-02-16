{
  inputs,
  profiles,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./gh-proxy.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      server
    ];
    ips.public.ipv4 = "34.51.244.108";
  };

  disko = import ./disko.nix;

  deployment.targetHost = lib.mkForce "34.51.244.108";

  environment.systemPackages = with pkgs; [
    nodejs_24
    gnumake
    git
    openclaw
    signal-cli
    gh
    gh-proxy
  ];

  users.users.julien.linger = true;

  systemd.network.enable = true;
  networking.useNetworkd = true;
  systemd.network.networks."30-wan" = {
    matchConfig.Name = "ens4";
    networkConfig.DHCP = "ipv4";
  };

  luj.nginx.enable = true;
  services.openssh.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
