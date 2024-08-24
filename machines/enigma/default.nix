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
    arch = "aarch64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ips.vpn.ipv4 = "100.100.45.21";
  };

  networking.hostName = "enigma";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "262144";
    }
  ];

  security.pam.services.swaylock = { };

  services.displayManager.autoLogin = {
    enable = true;
    user = "julien";
  };

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
    package = config.boot.kernelPackages.nvidiaPackages.beta;
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

  services.netbird.enable = true;

  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  programs.ssh.startAgent = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    ddcutil
    xorg.xinit
  ];

  #sound.enable = true;

  programs.adb.enable = true;

  environment.variables.WLR_NO_HARDWARE_CURSORS = "1";

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  services.hash-collection = {
    enable = true;
    collection-url = "https://reproducibility.nixos.social";
    tokenFile = "/home/julien/lila-secrets/tokenfile";
    secretKeyFile = "/home/julien/lila-secrets/secret.key";
  };

  system.stateVersion = "23.05";
}
