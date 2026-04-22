{
  pkgs,
  inputs,
  profiles,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./autorandr.nix
    ./boot.nix
    ./nvidia.nix
    ./stumpwm.nix
    ./syncthing.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips.vpn.ipv4 = "100.100.45.11";
    profiles = with profiles; [ remote-builders ];
  };

  luj.remote-builders.epyc = {
    enable = true;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    extraFeatures = [
      "benchmark"
      "big-parallel"
    ];
  };

  services.fwupd.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
  };

  services.picom = {
    enable = true;
    backend = "xr_glx_hybrid";
    vSync = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.tailscale.enable = true;
  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  services.libinput.touchpad.tapping = false;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  # tss group has access to TPM devices.
  users.users.julien.extraGroups = [ "tss" ];

  services.postgresql.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    wl-mirror
    texlive.combined.scheme-full
    mu
  ];

  networking.hosts = {
    "172.25.90.82" = [ "ducati-diavel" ];
  };

  services.printing = {
    enable = true;
    extraConf = ''
      JobPrivateAccess all
      JobPrivateValues none
    '';
    clientConf = ''
      ServerName localhost
      Encryption Required
      User jmalka
    '';
  };

  environment.variables.CUPS_USER = "jmalka";

  security.pam.services.swaylock = { };

  services.gnome.gnome-keyring.enable = true;

  virtualisation.docker.enable = true;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "ebe7fbd4451442b0"
    ];
  };

  # Desktop environment
  programs.xwayland.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  system.stateVersion = "23.05";
}
