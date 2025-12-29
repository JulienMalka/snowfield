{
  pkgs,
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

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.27";
    profiles = with profiles; [ syncthing ];
    syncthing.id = "CCOB6HQ-VXA5XTN-NIIDYCK-MQGHI6G-6G5BGOB-JEIDJXC-FWEPINX-NM2DHAH";

  };

  programs.fuse.userAllowOther = true;

  fileSystems."/persistent".neededForBoot = true;

  disko = import ./disko.nix;

  virtualisation.docker.enable = true;

  boot.loader.systemd-boot.enable = true;

  networking.wireless.enable = false;

  services.tailscale.enable = true;

  services.userborn.enable = true;

  networking.networkmanager.enable = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  boot.initrd = {
    luks.devices.root = {
      crypttabExtraOpts = [ "fido2-device=auto" ];
      device = "/dev/nvme0n1p4";
    };
    systemd.enable = true;

  };

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

  programs.ssh.knownHosts."epyc.infra.newtype.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
  ];

  security.pam.services.swaylock = { };

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xterm.enable = true;
  services.xserver.enable = true;
  services.xserver.autoRepeatDelay = 250;
  services.xserver.autoRepeatInterval = 30;

  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
      EXWM=true ${pkgs.emacs}/bin/emacs -l /home/julien/.emacs.d/exwm-config.el
    '';
  };

  services.gnome.gnome-keyring.enable = true;
  system.stateVersion = "26.05";
}
