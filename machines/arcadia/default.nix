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
    # TODO: Fix colmena deployment
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.10";
    profiles = with profiles; [ syncthing ];
    syncthing.id = "PUOXK5U-OR4NX3V-ZDWWZIN-HX3AVPS-VFMPGVC-7BL3R7R-UIDRQVF-4FXEDQP";

  };

  boot.initrd.systemd.enable = true;

  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
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
    users.julien = {
      directories = [
        "dev"
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        ".local/share/direnv"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        "Maildir"
      ];
      files = [
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  fileSystems."/persistent".neededForBoot = true;

  disko = import ./disko.nix;

  virtualisation.docker.enable = true;

  boot.loader.systemd-boot.enable = true;

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
  system.stateVersion = "25.05";
}
