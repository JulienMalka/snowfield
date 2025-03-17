{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  emacs-from-overlay = pkgs.emacsWithPackagesFromUsePackage {
    config = ../../../emacs-config/ReadMe.org;
    package = pkgs.emacs-igc;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [ epkgs.exwm ];
  };

in
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./syncthing.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    # TODO: Fix colmena deployment
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.12";

  };

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  programs.fuse.userAllowOther = true;

  fileSystems."/persistent".neededForBoot = true;

  disko = import ./disko.nix;

  boot.loader.systemd-boot.enable = true;

  networking.wireless.enable = false;

  services.tailscale.enable = true;

  networking.networkmanager.enable = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [ "x86_64-linux" ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
  ];

  security.pam.services.swaylock = { };

  programs.ssh.startAgent = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xterm.enable = true;
  services.xserver.enable = true;

  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
      ${emacs-from-overlay}/bin/emacs -l /home/julien/.emacs.d/exwm-config.el
    '';
  };

  services.gnome.gnome-keyring.enable = true;
  system.stateVersion = "25.05";
}
