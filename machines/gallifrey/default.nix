{
  config,
  pkgs,
  inputs,
  profiles,
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
    profiles = with profiles; [
      sound
      syncthing
    ];
    syncthing.id = "2ATHIGB-OEVIG7S-HHXN2C7-T7VPNJ2-UQTLQ45-HAGXL23-ZMJNNMJ-EO4EMAT";
    ips.vpn.ipv4 = "100.100.45.19";
  };

  boot.initrd.systemd.enable = true;

  services.fwupd.enable = true;
  networking.hostName = "gallifrey";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.postgresql.enable = true;

  services.hash-collection = {
    enable = true;
    collection-url = "https://reproducibility.nixos.social";
    tokenFile = config.age.secrets.lila-token.path;
    secretKeyFile = config.age.secrets.lila-key.path;
  };
  nix.settings.trusted-users = [
    "queued-build-hook"
  ];

  age.secrets.lila-token = {
    file = ./secrets/lila-token.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };

  age.secrets.lila-key = {
    file = ./secrets/lila-key.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };

  networking.networkmanager.enable = true;

  programs.ssh.knownHosts."epyc.infra.newtype.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";

  programs.ssh.knownHosts."builder.luj.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2z+S1+Q1hvLP5BTr36ao/NTy4Szo2OGq2iguwL4/zp";

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
  #services.userborn.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "262144";
    }
  ];

  disko = import ./disko.nix;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c900",MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c900", MODE="0666"
  '';

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.xwayland.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [

      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [
          "x86_64-linux"
        ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
      {
        hostName = "builder.luj.fr";
        maxJobs = 5;
        systems = [
          "x86_64-linux"
        ];
        sshUser = "remote";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }

    ];
  };

  machine.meta.zones."luj.fr".subdomains.builder.A = [ "34.142.35.193" ];

  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    ddcutil
    lcli
    xorg.xinit
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tailscale-status
    gnomeExtensions.appindicator
    gnome-tweaks
    pkgs.firefoxpwa
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

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
        ".zotero"
        ".cache/zotero"
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        ".config/cosmic"
        ".local/share/direnv"
        ".local/state/cosmic-comp"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/pika-backup"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        ".cache/mu"
        "Maildir"
      ];
      files = [
        ".config/gnome-initial-setup-done"
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
        ".local/share/com.ranfdev.Notify.sqlite"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  fileSystems."/persistent".neededForBoot = true;

  system.stateVersion = "25.11";
}
