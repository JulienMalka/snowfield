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
      deepseek-v4-flash
    ];
    ips = {
      vpn.ipv4 = "100.100.45.44";
      vpn.ipv6 = "fd7a:115c:a1e0::2c";
    };
  };

  hardware.dgx-spark.enable = true;

  # Head of the two-Spark vLLM cluster: serves the API, on the VPN.
  luj.vllm-cluster = {
    nodeRank = 0;
    interconnect.addresses = {
      enp1s0f0np0 = "192.168.100.11";
      enP2p1s0f0np0 = "192.168.101.11";
    };
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

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
