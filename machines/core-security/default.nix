{
  config,
  pkgs,
  lib,
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
      local.ipv4 = "192.168.0.175";
      vpn.ipv4 = "100.100.45.14";
      public.ipv6 = "2a01:e0a:de4:a0e1:40f0:8cff:fe31:3e94";
      vpn.ipv6 = "fd7a:115c:a1e0::e";
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  deployment.tags = [ "server" ];

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
      hostname = "https://auth.julienmalka.me";
      hostname-admin-url = "https://auth.julienmalka.me";
      http-port = 8080;
      proxy-headers = "forwarded";
      http-enabled = true;
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

  security.acme.certs."ca.luj".server = lib.mkForce "https://127.0.0.1:8444/acme/acme/directory";

  systemd.services."step-ca".after = [ "keycloak.service" ];

  # TODO: Remove when keycloak is update in stable channel
  nixpkgs.config.permittedInsecurePackages = [ "keycloak-23.0.6" ];

  system.stateVersion = "22.11";
}
