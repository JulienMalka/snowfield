{
  inputs,
  profiles,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hermes.nix
    ./hardware.nix
    ./home-julien.nix
    ./gh-proxy.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    syncthing = {
      id = "OENSRAR-757U7ZP-U3YBWWP-QYSW2D5-TSRROBK-LDZZOOL-RHN7JWI-VU24IQH";
      folders = [
        "notes"
        "agentic-workflows"
      ];
    };
    profiles = with profiles; [
      vm-simple-network
      server
      monitoring
    ];
    ips = {
      # Behind the Hetzner host's NAT like the other VMs on the cluster. The
      # v6 continues the hand-assigned eb2:aaaa:: series (gustave ::45,
      # biblios ::46) and is what vm-simple-network statically configures
      # on ens18.
      public.ipv4 = "77.42.114.11";
      public.ipv6 = "2a01:4f9:3090:2b8c:eb2:aaaa::47";
      vpn.ipv4 = "100.100.45.28";
    };
  };

  # Bootstrapped with `nixmoxer jacques`, which creates the VM from this block
  # and installs the configuration from a generated ISO. Changing these values
  # afterwards has no effect on the running VM.
  virtualisation.proxmox = {
    node = "pve";
    vmid = 122;
    cores = 4;
    memory = 8192;
    # systemd-boot needs UEFI; same shape as gustave (vmid 119).
    bios = "ovmf";
    efidisk0.file = "local-zfs:1";
    # The CPU type is flipped to x86-64-v3 over the API after creation
    # (qemu64 SIGILLs modern SIMD binaries): the locked proxmox-nixos
    # can't express `cpu.cputype` without tripping on defaultless
    # submodule options that its nixmoxer JSON dump then evaluates.
    autoInstall = true;
    net = [
      {
        model = "virtio";
        bridge = "vmbr0";
      }
    ];
    # The dir storage ("local") only holds ISOs; VM disks live on the pool.
    scsi = [ { file = "local-zfs:60"; } ];
  };

  disko = import ./disko.nix;

  deployment.targetHost = lib.mkForce "100.100.45.28";

  environment.systemPackages = with pkgs; [
    gh
    gh-proxy
    git
    hermes-agent
    signal-cli
  ];

  users.users.julien.linger = true;

  services.tailscale.enable = true;

  luj.nginx.enable = true;
  services.openssh.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
