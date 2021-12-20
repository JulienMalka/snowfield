{ config, pkgs, lib, modulesPath, inputs, ... }:

{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      #    (import "${inputs.hardware}/lenovo/thinkpad/p14s/amd/gen2")
    ];


  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    amdvlk
  ];

  hardware.opengl = {
    driSupport = lib.mkDefault true;
    driSupport32Bit = lib.mkDefault true;
  };


  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableAllFirmware;

  boot.kernelParams = [ "acpi_backlight=native" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot = {
    kernelModules = [ "acpi_call" "kvm-amd" "amdgpu" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };









  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  sound.enable = true;


  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  networking.hostName = "macintosh"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  networking.useDHCP = false;
  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  programs.steam.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };


  nixpkgs.config.allowUnfree = true;

  hardware.trackpoint = {
    enable = true;
    speed = 80;
    sensitivity = 220;
    emulateWheel = true;
    device = "TPPS/2 Elan TrackPoint";
  };



  programs.gnupg.agent.enable = true;


  services = {

    tlp.enable = true;

    xserver = {
      videoDrivers = [ "amdgpu" ];
      enable = true;
      layout = "fr";
      libinput.enable = false;
      libinput.touchpad.tapping = false;
      displayManager.sddm.enable = true;
      desktopManager.xterm.enable = true;
    };

  };


  environment.systemPackages = with pkgs; [
    wget
    git
    rxvt_unicode
    xorg.xbacklight
  ];
  environment.variables.EDITOR = "urxvt";

  programs.dconf.enable = true;


  networking.firewall.enable = false;

  system.stateVersion = "21.11"; # Did you read the comment?
  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "sdhci_pci" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3e01f61b-c580-4078-94be-192f7aed5c5a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2799-DF20";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/44dadc95-a61e-40db-93d7-ada237f1e53b"; }];



  # HOME

  luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.i3.enable = true;
    luj.polybar.enable = true;
    home.packages = with pkgs; [
      unstable.rofi
      unstable.firefox
      feh
      meld
      vlc
      nerdfonts
      font-awesome
      python3
      texlive.combined.scheme-full
      nodejs
      fira-code
      neomutt
      htop
      evince
      mosh
      signal-desktop
      flameshot
      ctags
      ungoogled-chromium
    ];


    home.keyboard = {
      layout = "fr";
    };



    gtk = {
      enable = true;
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
    };


    fonts.fontconfig.enable = true;

    xsession.enable = true;


    home.stateVersion = "21.11";



  };








}

