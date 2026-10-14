{
  inputs,
  profiles,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./yellow.nix
    ./home-assistant.nix
  ];

  disko = import ./disko.nix;

  machine.meta = {
    arch = "aarch64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    profiles = with profiles; [
      server
      monitoring
    ];
    ips.vpn = {
      ipv4 = "100.100.45.29";
      ipv6 = "fd7a:115c:a1e0::1d";
    };
    defaultInterface = "end0";
  };

  system.stateVersion = "26.05";
}
