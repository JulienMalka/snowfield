{ config, pkgs, lib, modulesPath, inputs, ... }:

{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware.nix
      ./home-julien.nix
    ];


  networking.hostName = "macintosh"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

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


  services.tlp.enable = true;
  services.xserver = {
    videoDrivers = [ "amdgpu" ];
    enable = true;
    layout = "fr";
    libinput.enable = false;
    libinput.touchpad.tapping = false;
    displayManager.sddm.enable = true;
    desktopManager.xterm.enable = true;
  };



  environment.systemPackages = with pkgs; [
    wget
    git
    rxvt_unicode
    xorg.xbacklight
    neovim
  ];

  environment.variables.EDITOR = "nvim";

  programs.dconf.enable = true;

  system.stateVersion = "21.11"; 

}

