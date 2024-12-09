{
  config,
  pkgs,
  lib,
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
    # TODO: Fix colmena deployment
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.11";
  };

  # Boot stuff
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.initrd.systemd.enable = true;
  boot.initrd.clevis = {
    enable = true;
    devices."cryptroot".secretFile = ./root.jwe;
  };
  boot.initrd.systemd.tpm2.enable = true;

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

  networking.hostName = "fischer";

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable OpenGL
  hardware.graphics.enable = true;

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
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  programs.dconf.enable = true;

  security.polkit.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.julien.extraGroups = [ "tss" ]; # tss group has access to TPM devices

  services.postgresql.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    unstable.diffoscope
    sbctl
    wl-mirror
    texlive.combined.scheme-full
    mu
  ];

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

  environment.variables = {
    CUPS_USER = "jmalka";
  };

  security.pam.services.swaylock = { };

  programs.ssh.startAgent = true;

  services.gnome.gnome-keyring.enable = true;

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  virtualisation.docker.enable = true;

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
