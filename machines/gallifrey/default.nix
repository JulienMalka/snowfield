{
  config,
  pkgs,
  inputs,
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
  };

  networking.hostName = "gallifrey";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
  #services.userborn.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "julien";
  };

  disko = import ./disko.nix;

  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
    };
    desktopManager.gnome.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  hardware.opengl.enable = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.xwayland.enable = true;
  services.postgresql.enable = true;

  programs.dconf.enable = true;
  services.emacs = {
    enable = true;
    package = pkgs.emacs29-gtk3;
  };

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

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
  ];

  environment.persistence."/persistent" = {
    hidemounts = true;
    directories = [
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  programs.fuse.userAllowOther = true;

  filesystems."/persistent".neededforboot = true;

  system.stateVersion = "24.11";
}
