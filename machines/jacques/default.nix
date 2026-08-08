{
  inputs,
  profiles,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./gh-proxy.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
      monitoring
    ];
    ips = {
      # Home NAT, like the other VMs on the cluster. The v6 continues the
      # hand-assigned eb2:aaaa:: series (gustave ::45, biblios ::46) and is
      # what vm-simple-network statically configures on ens18.
      public.ipv4 = "82.67.34.230";
      public.ipv6 = "2a01:e0a:de4:a0e1:eb2:aaaa::47";
      # TODO(julien): confirm once the VM has joined the tailnet — this is the
      # address the dead GCP jacques held, which its node entry still reserves.
      vpn.ipv4 = "100.100.45.21";
    };
  };

  # Bootstrapped with `nixmoxer jacques`, which creates the VM from this block
  # and installs the configuration from a generated ISO. Changing these values
  # afterwards has no effect on the running VM.
  virtualisation.proxmox = {
    # TODO(julien): pick the node and a free vmid (`qm list` on the cluster).
    node = "pve1";
    vmid = 121;
    cores = 4;
    memory = 8192;
    autoInstall = true;
    net = [
      {
        model = "virtio";
        bridge = "vmbr0";
      }
    ];
    scsi = [ { file = "local:40"; } ];
  };

  disko = import ./disko.nix;

  deployment.targetHost = lib.mkForce "100.100.45.21";

  environment.systemPackages = with pkgs; [
    gh
    gh-proxy
    git
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
