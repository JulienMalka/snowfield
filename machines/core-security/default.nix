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
    ./kanidm.nix
    ./step-ca.nix
    ./vaultwarden.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
      behind-sniproxy
      monitoring
    ];
    ips = {
      public.ipv4 = "82.67.34.230";
      local.ipv4 = "192.168.0.175";
      vpn.ipv4 = "100.100.45.14";
      public.ipv6 = "2a01:e0a:de4:a0e1:40f0:8cff:fe31:3e94";
      vpn.ipv6 = "fd7a:115c:a1e0::e";
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  deployment.tags = [ "server" ];

  services.openssh.enable = true;

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  luj.nginx.enable = true;

  system.stateVersion = "22.11";
}
