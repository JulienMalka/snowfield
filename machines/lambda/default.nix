{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lambda";

  time.timeZone = "Europe/Paris";

  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;

  services.uptime-kuma.enable = true;
  services.uptime-kuma.settings = {
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };

  services.ntfy-sh.enable = true;
  services.ntfy-sh.settings = {
    listen-http = ":8080";
    behind-proxy = true;
    upstream-base-url = "https://ntfy.sh";
    base-url = "https://notifications.julienmalka.me";
    auth-file = "/srv/ntfy/user.db";
    auth-default-access = "deny-all";
  };

  services.nginx.virtualHosts."status.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."uptime.luj".server = "https://ca.luj:8444/acme/acme/directory";

  services.nginx.virtualHosts."uptime.luj" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."notifications.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8080";
      proxyWebsockets = true;
    };
  };

  networking.nameservers = [ "100.127.245.71" "9.9.9.9" ];
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };



  services.grafana.enable = true;
  services.grafana.settings.server.http_port = 3000;
  services.victoriametrics.enable = true;

  services.nginx.virtualHosts."monitoring.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };


  security.acme.certs."prometheus.luj".server = "https://ca.luj:8444/acme/acme/directory";
  services.nginx.virtualHosts."prometheus.luj" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8428";
      extraConfig = ''
         allow 100.10.10.0/8;
        deny all;
      '';
    };
  };




  security.acme.acceptTerms = true;
  security.acme.defaults.email = "julien@malka.sh";


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


  services.openssh = {
    enable = true;
    ports = [ 45 ];
    permitRootLogin = "yes";
    openFirewall = true;
  };


  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9Uzb7szWlux7HuxLZej9cBR5MhLz/vaAPPfSoozt2k julien@enigma.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower"
  ];

  networking.firewall.allowedTCPPorts = [ 443 80 8428 ];
  networking.firewall.allowedUDPPorts = [ 443 80 8428 ];
  system.stateVersion = "22.11";
}
