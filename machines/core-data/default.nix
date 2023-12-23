{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware.nix
      ../../users/default.nix
      ../../users/julien.nix
      ./home-julien.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  deployment.targetHost = lib.mkForce "192.168.0.66";
  deployment.targetPort = lib.mkForce 45;

  security.acme.defaults.email = "julien@malka.sh";

  networking.hostName = "core-data";

  systemd.network.enable = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    networkConfig = {
      # start a DHCP Client for IPv4 Addressing/Routing
      DHCP = "ipv4";
      # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
      IPv6AcceptRA = true;
    };
    # make routing on this interface a dependency for network-online.target
    linkConfig.RequiredForOnline = "routable";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };
  console.keyMap = "fr";

  security.acme.acceptTerms = true;

  environment.systemPackages = with pkgs; [
    neovim
    tailscale
  ];

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  networking.firewall.checkReversePath = "loose";

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.tailscale.enable = true;


  # Photoprism
  services.photoprism = {
    enable = true;
    port = 2342;
    originalsPath = "/data/photos";
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
    dataDir = "/data/mysql";
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [{
      name = "photoprism";
      ensurePermissions = {
        "photoprism.*" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    clientMaxBodySize = "500m";
    virtualHosts = {
      "photos.malka.family" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2342";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_buffering off;
            proxy_http_version 1.1;
          '';
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

  security.pki.certificates = [
    ''-----BEGIN CERTIFICATE-----
MIIByzCCAXKgAwIBAgIQAcJCOR+99m5v3dHWQw5m9jAKBggqhkjOPQQDAjAwMRIw
EAYDVQQKEwlTYXVtb25OZXQxGjAYBgNVBAMTEVNhdW1vbk5ldCBSb290IENBMB4X
DTIyMDQyNDIwMDE1MFoXDTMyMDQyMTIwMDE1MFowODESMBAGA1UEChMJU2F1bW9u
TmV0MSIwIAYDVQQDExlTYXVtb25OZXQgSW50ZXJtZWRpYXRlIENBMFkwEwYHKoZI
zj0CAQYIKoZIzj0DAQcDQgAE5Sk6vYJcYlh4aW0vAN84MWr84TTVTTdsM2s8skH6
7fDsqNMb7FMwUMEAFwQRiADjYy3saU2Dogh2ESuB1dDFFqNmMGQwDgYDVR0PAQH/
BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFO5iTfZiutpsM7ja
mP3yuMIy6iNTMB8GA1UdIwQYMBaAFBWOQHe4eAeothQTmTNKiG/pAowGMAoGCCqG
SM49BAMCA0cAMEQCICu8u19I7RMfnQ7t3QXHP5fdUm/fX/puqF+jYSf9SZEoAiBc
oVcd0OfuAExWHhOMUZ0OV4bws9WCax333I+Pg4nDNw==
-----END CERTIFICATE-----''
    ''-----BEGIN CERTIFICATE-----
MIIBpTCCAUqgAwIBAgIRALevKnnElllot/cRNGjnUqUwCgYIKoZIzj0EAwIwMDES
MBAGA1UEChMJU2F1bW9uTmV0MRowGAYDVQQDExFTYXVtb25OZXQgUm9vdCBDQTAe
Fw0yMjA0MjQyMDAxNDlaFw0zMjA0MjEyMDAxNDlaMDAxEjAQBgNVBAoTCVNhdW1v
bk5ldDEaMBgGA1UEAxMRU2F1bW9uTmV0IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggq
hkjOPQMBBwNCAAQG356Ui437dBTSOiJILKjVkwrJMsXN3eba/T1N+IJeqRBfigo7
BW9YZfs1xIbMZ5wL0Zc/DsSEo5xCC7j4YaXro0UwQzAOBgNVHQ8BAf8EBAMCAQYw
EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUFY5Ad7h4B6i2FBOZM0qIb+kC
jAYwCgYIKoZIzj0EAwIDSQAwRgIhALdsEqiRa4ak5Cnin6Tjnel5uOiHSjoC6LKf
VfXtULncAiEA2gmqdr+ugFz5tvPdKwanroTiMTUMhhCRYVlQlyTApyQ=
-----END CERTIFICATE-----''
  ];


  system.stateVersion = "23.11";

}
