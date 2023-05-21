{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ../../users/default.nix
      ../../users/julien.nix
      ./home-julien.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  security.acme.defaults.email = "julien@malka.sh";

  networking.hostName = "core-security"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

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

  users.users.julien = {
    isNormalUser = true;
    description = "julien";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [ ];
  };

  security.acme.acceptTerms = true;

  environment.systemPackages = with pkgs; [
    neovim
    tailscale
  ];

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  networking.firewall.checkReversePath = "loose";


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


  networking.nameservers = [ "9.9.9.9" ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."vaults.malka.family" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };

  services.tailscale.enable = true;

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaults.malka.family";
      ROCKET_PORT = "8223";
      SIGNUPS_ALLOWED = false;
    };
    environmentFile = "/var/lib/vaultwarden.env";
  };

  services.keycloak = {
    enable = true;
    database.createLocally = true;
    database.passwordFile = "/run/secrets/keycloak";
    settings = {
      hostname = "auth.julienmalka.me";
      http-port = 8080;
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
  };

  services.nginx.virtualHosts."auth.julienmalka.me" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      extraConfig = '' 
      proxy_buffer_size   128k;
      proxy_buffers   4 256k;
      proxy_busy_buffers_size   256k;
      '';
    };
  };


  sops.secrets.keycloak = {
    owner = "root";
    sopsFile = ../../secrets/keycloak-db;
    format = "binary";
  };


  system.stateVersion = "22.11"; # Did you read the comment?

}
