{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];


  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "bin-cache";

  time.timeZone = "Europe/Paris";

  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;

  services.nginx.virtualHosts."cache.julienmalka.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8080";
      proxyWebsockets = true;
    };
  };

  networking.nameservers = [ "100.100.45.5" "9.9.9.9" ];
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };


  sops.secrets.attic-secret = {
    owner = "root";
    path = "/etc/atticd.env";
    format = "binary";
    sopsFile = ../../secrets/attic-secret;
  };

  services.atticd = {
    enable = true;
    # Replace with absolute path to your credentials file
    credentialsFile = "/etc/atticd.env";

    settings = {
      listen = "[::]:8080";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
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
