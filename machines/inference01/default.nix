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
    ./vllm.nix
    ./hotspot.nix
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
      # TODO: fill in real addresses once inference01 is on the network.
      public.ipv4 = "127.0.0.1";
    };
  };

  deployment.targetHost = lib.mkForce "100.100.45.44";

  hardware.dgx-spark.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  nixpkgs.overlays = [
    (import "${inputs.nixos-dgx-spark}/overlays/fixes.nix")
  ];

  disko = import ./disko.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Native builds of the CUDA stack (torch, vllm, magma, llvm/clang) are
  # memory-heavy; nix's default concurrency ran several at once and, alongside
  # the resident vLLM, OOM'd the 121 GB Spark. Cap how many derivations build
  # in parallel and how many threads each gets.
  nix.settings = {
    max-jobs = 2;
    cores = 12;
  };

  networking.networkmanager.enable = true;
  # The wifi link (used while the wired port is down) power-saves on idle:
  # the NIC sleeps, takes ~3.5s to wake, and drops packets in between, so
  # tailscale (DERP-relayed, no direct path) flaps and idle peers time out.
  # Keep the radio awake so the link stays reachable.
  networking.networkmanager.wifi.powersave = false;
  networking.useDHCP = lib.mkForce false;
  systemd.network.enable = lib.mkForce false;

  system.stateVersion = "25.11";
}
