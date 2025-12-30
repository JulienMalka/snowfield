{
  inputs,
  profiles,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./home-julien.nix

  ];

  boot.loader.grub.enable = false;
  boot.isContainer = true;

  networking.useNetworkd = true;

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ips = {
      public.ipv6 = "2001:bc8:38ee:100:f837:7fff:fe77:7154";
      public.ipv4 = "192.168.0.1";
    };
    profiles = with profiles; [
      server
    ];
  };

  system.build.installBootLoader = pkgs.writeScript "install-sbin-init.sh" ''
    #!${pkgs.runtimeShell}
    ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
  '';

  system.activationScripts.installInitScript = lib.mkForce ''
    ${pkgs.coreutils}/bin/ln -fs $systemConfig/init /sbin/init
  '';

  deployment.targetHost = lib.mkForce "2001:bc8:38ee:100:f837:7fff:fe77:7154";

  services.hash-collection = {
    enable = true;
    collection-url = "https://reproducibility.nixos.social";
    tokenFile = config.age.secrets.lila-token.path;
    secretKeyFile = config.age.secrets.lila-key.path;
  };
  nix.settings.trusted-users = [
    "queued-build-hook"
  ];

  age.secrets.lila-token = {
    file = ./secrets/lila-token.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };

  age.secrets.lila-key = {
    file = ./secrets/lila-key.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };

  networking.useHostResolvConf = false;

  systemd.network.enable = true;
  services.resolved.enable = true;
  systemd.network.networks."10-host01" = {
    matchConfig.Name = "host01";

    dns = [
      # DNS64 servers
      "2001:4860:4860::6464"
      "2001:4860:4860::64"
    ];

    networkConfig.Address = "2001:bc8:38ee:100:f837:7fff:fe77:7154/56";

    routes = [
      {
        Gateway = "2001:bc8:38ee:100::100";
        Destination = "64:ff9b::/96";
      }
    ];
  };

  disko = import ./disko.nix;

  system.stateVersion = "25.05";
}
