{ pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  systemd.network.enable = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    networkConfig = {
      DHCP = "ipv4";
      Address = "2a01:e0a:de4:a0e1:be24:11ff:fe09:638d";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Photoprism
  services.photoprism = {
    enable = true;
    port = 2342;
    originalsPath = "/data/photos";
    passwordFile = "/srv/photoprism";
    importPath = "import";
    address = "0.0.0.0";
    settings = {
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_SITE_URL = "http://photos.malka.family:2342";
      PHOTOPRISM_SITE_TITLE = "My PhotoPrism";
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [
      {
        name = "photoprism";
        ensurePermissions = {
          "photoprism.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx = {
    clientMaxBodySize = "500m";
    virtualHosts = {
      "photos.malka.family" = {
        forceSSL = true;
        enableACME = true;
        http2 = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:2342";
          proxyWebsockets = true;
        };
      };
    };
  };

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  system.stateVersion = "23.11";
}
