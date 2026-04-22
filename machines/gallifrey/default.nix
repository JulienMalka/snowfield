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
    ./hash-collection.nix
    ./nvidia.nix
    ./preservation.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    profiles = with profiles; [
      emacs
      preservation
      remote-builders
      sound
      syncthing
    ];
    syncthing.id = "2ATHIGB-OEVIG7S-HHXN2C7-T7VPNJ2-UQTLQ45-HAGXL23-ZMJNNMJ-EO4EMAT";
    ips.vpn.ipv4 = "100.100.45.19";
  };

  luj.remote-builders = {
    epyc = {
      enable = true;
      extraFeatures = [ "big-parallel" ];
    };
    builder-luj-fr.enable = true;
  };

  # builder.luj.fr is a GCE instance; publish its static IP under our
  # authoritative zone so the name resolves without an external lookup.
  machine.meta.zones."luj.fr".subdomains.builder.A = [ "34.142.35.193" ];

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.fwupd.enable = true;

  disko = import ./disko.nix;

  services.postgresql.enable = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    plugins = [ pkgs.networkmanager-openvpn ];
  };
  services.resolved.enable = true;

  # Raise the fd soft limit for interactive sessions; leptos-based projects
  # trip the default on large node_modules trees.
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "262144";
    }
  ];

  # Allow the Logitech MX Master to be claimed from userspace for solaar.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c900",MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c900", MODE="0666"
  '';

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  programs.dconf.enable = true;
  programs.fuse.userAllowOther = true;
  security.polkit.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    ddcutil
    lcli
    xinit
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tailscale-status
    gnomeExtensions.appindicator
    gnome-tweaks
    firefoxpwa
  ];

  system.stateVersion = "25.11";
}
