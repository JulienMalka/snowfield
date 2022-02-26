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
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.nameservers = lib.mkForce [ "10.100.0.2" ];
  networking.networkmanager.insertNameservers = [ "10.100.0.2" ];
  networking.resolvconf.dnsExtensionMechanism = false;
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.9/24" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";

      peers = [
        {
          allowedIPs = [ "10.100.0.0/24" ];
          publicKey = "hz+h9Oque5h+Y/WzOUnai3e9UfIfDsvtqmQH0xycIzs=";
          endpoint = "212.129.40.11:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };


}

