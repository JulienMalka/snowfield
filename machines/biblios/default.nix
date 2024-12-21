{
  inputs,
  profiles,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./garage.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
      behind-sniproxy
    ];
    ips = {
      public.ipv4 = "82.67.34.230";
      vpn.ipv4 = "100.64.0.2";
      public.ipv6 = "2a01:e0a:de4:a0e1:eb2:aaaa::46";
      vpn.ipv6 = "fd7a:115c:a1e0::27";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  luj.nginx.enable = true;

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
      "/srv"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  fileSystems."/srv".neededForBoot = true;

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
}
