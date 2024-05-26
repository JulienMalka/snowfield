{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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

  services.openssh.enable = true;

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  luj.nginx.enable = true;
  services.nginx.virtualHosts."vaults.malka.family" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };

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
    database.passwordFile = "/run/agenix/keycloak-db";
    settings = {
      hostname = "auth.julienmalka.me";
      hostname-admin-url = "https://auth.julienmalka.me";
      http-port = 8080;
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
    themes = {
      keywind = pkgs.keycloak-keywind;
    };
  };

  services.nginx.virtualHosts."auth.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      extraConfig = ''
        proxy_buffer_size   128k;
        proxy_buffers   4 256k;
        proxy_busy_buffers_size   256k;
      '';
    };
  };

  age.secrets.keycloak-db.file = ../../secrets/keycloak-db.age;

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  services.step-ca.enable = true;
  services.step-ca.intermediatePasswordFile = "/root/capw";
  services.step-ca.address = "100.100.45.14";
  services.step-ca.port = 8444;
  services.step-ca.settings = builtins.fromJSON ''
    {}
  '';

  systemd.services."step-ca".serviceConfig.ExecStart = [
    "" # override upstream
    "${pkgs.step-ca}/bin/step-ca /etc/smallstep/ca_prod.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
  ];

  services.nginx.virtualHosts."ca.luj" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8444";
    };
  };

  security.acme.certs."ca.luj".server = "https://127.0.0.1:8444/acme/acme/directory";

  systemd.services."step-ca".after = [ "keycloak.service" ];

  # TODO: Remove when keycloak is update in stable channel
  nixpkgs.config.permittedInsecurePackages = [ "keycloak-23.0.6" ];

  system.stateVersion = "22.11";
}
