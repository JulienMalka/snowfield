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
    ./desktop.nix
    ./preservation.nix
    ./reka.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips.vpn.ipv4 = "100.100.45.27";
    profiles = with profiles; [
      emacs
      preservation
      remote-builders
      syncthing
    ];
    syncthing.id = "CCOB6HQ-VXA5XTN-NIIDYCK-MQGHI6G-6G5BGOB-JEIDJXC-FWEPINX-NM2DHAH";
  };

  luj.remote-builders = {
    epyc = {
      enable = true;
      maxJobs = 16;
      extraFeatures = [ "big-parallel" ];
    };
    builder-luj-fr.enable = true;
  };

  disko = import ./disko.nix;

  boot.loader.systemd-boot.enable = true;
  boot.initrd = {
    luks.devices.crypted = {
      crypttabExtraOpts = [ "fido2-device=auto" ];
      bypassWorkqueues = true;
    };
    systemd.enable = true;
  };

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 disable_11be=Y
  '';

  boot.kernelParams = [
    "xe.enable_psr=0"
    "intel_idle.max_cstate=1"
  ];

  # iwlwifi's TSO/GSO implementations periodically wedge this machine's wifi;
  # disabling the offloads once the link is up keeps the connection stable.
  systemd.services.iwlwifi-tso-fix = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K wlp0s20f3 tso off gso off";
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  hardware.enableRedistributableFirmware = true;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables = {
      OLLAMA_VULKAN = "1";
      OLLAMA_FLASH_ATTENTION = "0";
      GGML_VK_DISABLE_INTEGER_DOT_PRODUCT = "1";
    };
  };

  services.tailscale.enable = true;
  services.userborn.enable = true;
  networking.networkmanager.enable = true;
  services.dbus.enable = true;
  programs.dconf.enable = true;
  programs.fuse.userAllowOther = true;
  services.libinput.touchpad.tapping = false;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    tailscale
    brightnessctl
    sbctl
  ];

  system.stateVersion = "26.05";
}
