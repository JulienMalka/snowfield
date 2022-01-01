{ config, pkgs, lib, modulesPath, inputs, ... }:

{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];


  networking.hostName = "macintosh";
  networking.networkmanager.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

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


  programs.dconf.enable = true;

  system.stateVersion = "21.11"; 

}

