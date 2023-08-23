{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "x2100";

  networking.wireless.enable = false;

  programs.hyprland.enable = true;
  programs.hyprland.package = pkgs.hyprland;
  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.logind.lidSwitch = "suspend";

  services.xserver = {
    enable = true;
    layout = "fr";
    displayManager.gdm.enable = true;
  };

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;


  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  services.tlp.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
  ];

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  services.davfs2 = {
    enable = true;
  };

  security.pam.services.swaylock = { };

  programs.ssh.startAgent = true;

  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  services.autofs = {
    enable = true;
    debug = true;
    autoMaster =
      let
        mapConf = pkgs.writeText "auto" ''
          nuage -fstype=davfs,uid=1000,file_mode=600,dir_mode=700,conf=/home/julien/.davfs2/davfs2.conf,rw :https\://nuage.malka.family/remote.php/webdav/
        '';
      in
      ''
        /home/julien/clouds file:${mapConf}
      '';
  };

  system.stateVersion = "23.05";

}


