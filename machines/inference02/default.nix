{
  inputs,
  profiles,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    "${inputs.nixos-dgx-spark}/modules/dgx-spark.nix"
  ];

  machine.meta = {
    arch = "aarch64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    profiles = with profiles; [
      server
      monitoring
    ];
    ips = {
      # Wired LAN (DHCP on enP7s7) sits inside tailscale's 100.64/10 CGNAT
      # range, like inference01's.
      local.ipv4 = "100.86.42.249";
      vpn.ipv4 = "100.100.45.15";
    };
  };

  hardware.dgx-spark.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  nixpkgs.overlays = [
    (import "${inputs.nixos-dgx-spark}/overlays/fixes.nix")
  ];

  disko = import ./disko.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Same budget as inference01: native CUDA builds are memory-heavy.
  nix.settings = {
    max-jobs = 2;
    cores = 12;
  };

  # Wifi via NetworkManager, like inference01; keep the radio awake so
  # tailscale doesn't flap on an idle link.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.useDHCP = lib.mkForce false;
  systemd.network.enable = lib.mkForce false;

  system.stateVersion = "25.11";
}
