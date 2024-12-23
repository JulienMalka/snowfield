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
    profiles = with profiles; [ sound ];
    ips.vpn.ipv4 = "100.100.45.35";
  };

  networking.hostName = "gallifrey";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  programs.ssh.knownHosts."epyc.infra.newtype.fr".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";

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

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.xwayland.enable = true;
  services.postgresql.enable = true;

  programs.dconf.enable = true;

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "benchmark"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
    ];
  };

  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  programs.ssh.startAgent = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    ddcutil
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
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
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

  system.stateVersion = "24.11";
}
