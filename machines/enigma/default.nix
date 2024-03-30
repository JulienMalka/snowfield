{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware.nix
      ./home-julien.nix
    ];

  networking.hostName = "enigma";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.gnome.gnome-browser-connector.enable = true;

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  security.pam.loginLimits = [{
    domain = "*";
    type = "-";
    item = "nofile";
    value = "262144";
  }];

  security.pam.services.swaylock = { };


  services.xserver = {
    enable = true;
    layout = "fr";
    xkbVariant = "";
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = "julien";
      };
    };
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;


    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };



  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  programs.xwayland.enable = true;
  programs.hyprland =
    {
      enable = true;
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  programs.dconf.enable = true;
  services.emacs = {
    enable = true;
    package = pkgs.emacs29-gtk3;
  };

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  security.polkit.enable = true;

  nix = {
    package = lib.mkForce pkgs.nix;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [ "x86_64-linux" ];
        sshUser = "root";
        supportedFeatures = [ "kvm" "nixos-test" "benchmark" "big-parallel" ];
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
  ];

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.adb.enable = true;



  environment.variables.WLR_NO_HARDWARE_CURSORS = "1";

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  system.stateVersion = "23.05";

}



