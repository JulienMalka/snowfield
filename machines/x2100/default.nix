{ config, pkgs, lib, inputs, nixpkgs-patched, ... }:

{
  imports =
    [
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
      ../../share.nix
    ];


  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.initrd.systemd.enable = true;
  sound.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.pulseaudio.enable = lib.mkForce false;

  services.postgresql.enable = true;

  networking.hostName = "x2100";

  networking.wireless.enable = false;

  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.logind.lidSwitch = "suspend";

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = null;
    useXkbConfig = true; # use xkbOptions in tty.
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  services.tlp.enable = false;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.julien.extraGroups = [ "tss" ]; # tss group has access to TPM devices



  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [ "x86_64-linux" ];
        sshUser = "root";
        supportedFeatures = [ "kvm" "nixos-test" ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
    ];
  };


  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    wl-mirror
  ];


  networking.wireguard.interfaces.rezo = {           
  ips = [ "fd81:fb3a:50cc::200/128" ];
    privateKeyFile = "/root/wg-private";
     peers = [
       {
         publicKey = "srQPT9ZjXBKyJ7R1mvXYMZNy+NcnHMy5qE1WGZDfmnc=";
         allowedIPs = [ "fd81:fb3a:50cc::/48" ];
         endpoint = "129.199.146.230:25351";
       }
     ];                                                                                                          
   };

  

  services.hash-collection = {
    enable = true;
    retries = 1;
    collection-url = "http://localhost:8000";
    tokenFile = "/home/julien/token";
  }; 

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;


  security.pam.services.swaylock = { };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  #  programs.sway.package = null;
  programs.ssh.startAgent = true;

  services.gnome.gnome-keyring.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
    "zotero-6.0.27"
  ];

  system.stateVersion = "23.05";

}



