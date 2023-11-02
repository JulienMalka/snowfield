{ config, pkgs, lib, inputs, nixpkgs-patched, ... }:

{
  imports =
    [
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];



  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  sound.enable = true;
  #hardware.pulseaudio.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    wireplumber.enable = true;

  };

  services.postgresql.enable = true;

  networking.hostName = "telecom";

  networking.wireless.enable = false;

  programs.hyprland.enable = true;
  programs.hyprland.package = pkgs.hyprland;
  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.xserver = {
    enable = true;
    layout = "fr";
    displayManager.gdm.enable = true;
  };

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;


  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  services.tlp.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.julien.extraGroups = [ "tss" ]; # tss group has access to TPM devices

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    wl-mirror
  ];

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;


  security.pam.services.swaylock = { };

  programs.ssh.startAgent = true;

  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  services.gnome.gnome-keyring.enable = true;

  system.stateVersion = "23.05";

}



