{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../users/default.nix
    ../../users/julien.nix
    ./home-julien.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  systemd.network.enable = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    networkConfig = {
      DHCP = "ipv4";
      Address = "2a01:e0a:de4:a0e1:95c9:b2e2:e999:1a45";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
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
