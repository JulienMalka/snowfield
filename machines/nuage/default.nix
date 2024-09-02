{
  config,
  pkgs,
  inputs,
  profiles,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
    ];
    ips = {
      public.ipv4 = "82.67.34.230";
      local.ipv4 = "192.168.0.101";
      vpn.ipv4 = "100.100.45.28";
      public.ipv6 = "2a01:e0a:de4:a0e1:95c9:b2e2:e999:1a45";
      vpn.ipv6 = "fd7a:115c:a1e0::1c";
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    https = true;
    hostName = "nuage.malka.family";
    config = {
      overwriteProtocol = "https";
      dbtype = "mysql";
      dbuser = "test";
      dbhost = "localhost"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nuage";
      dbpassFile = "/srv/nextclouddbpass";
      adminpassFile = "/srv/nextcloudadminpass";

      adminuser = "admin";
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

  system.stateVersion = "22.05";
}
