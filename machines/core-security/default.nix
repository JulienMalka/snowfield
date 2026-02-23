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
    ./kanidm.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
      behind-sniproxy
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

  age.secrets.step-ca-intermediate-password = {
    file = ./step-ca-intermediate-password.age;
    owner = "step-ca";
  };
  age.secrets.step-ca-oidc-secret = {
    file = ./step-ca-oidc-secret.age;
    owner = "step-ca";
  };
  age.secrets.step-ca-jwk-encrypted-key = {
    file = ./step-ca-jwk-encrypted-key.age;
    owner = "step-ca";
  };

  services.step-ca = {
    enable = true;
    address = "100.100.45.14";
    port = 8444;
    intermediatePasswordFile = config.age.secrets.step-ca-intermediate-password.path;
    settings = {
      root = "/var/lib/step-ca/.step/certs/root_ca.crt";
      federatedRoots = null;
      crt = "/var/lib/step-ca/.step/certs/intermediate_ca.crt";
      key = "/var/lib/step-ca/.step/secrets/intermediate_ca_key";
      address = ":8444";
      dnsNames = [
        "ca.luj"
        "100.100.45.14"
        "127.0.0.1"
      ];
      ssh = {
        hostKey = "/var/lib/step-ca/.step/secrets/ssh_host_ca_key";
        userKey = "/var/lib/step-ca/.step/secrets/ssh_user_ca_key";
      };
      logger.format = "text";
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/.step/db";
        badgerFileLoadingMode = "";
      };
      authority = {
        provisioners = [
          {
            type = "OIDC";
            name = "Luj SSO";
            clientID = "step";
            clientSecret = "@step-ca-oidc-secret@";
            configurationEndpoint = "https://auth.luj.fr/oauth2/openid/step/.well-known/openid-configuration";
            listenAddress = ":10000";
            claims.enableSSHCA = true;
          }
          {
            type = "JWK";
            name = "ssh-host-provisioner";
            key = {
              use = "sig";
              kty = "EC";
              kid = "R0DKo6XYZnKj0dPc36ORzsb_ntEzKYPrKni7qpHuna4";
              crv = "P-256";
              alg = "ES256";
              x = "bgFOoF_PUWZLDe9J3auTx4VOY9jXIuJHXLr70ZRSqM8";
              y = "1dsaXCxO4D5ebyY_lEL4cjNjfDYYGBfx69qF5UGVG-U";
            };
            encryptedKey = "@step-ca-jwk-encrypted-key@";
            claims.enableSSHCA = true;
          }
          {
            type = "ACME";
            name = "acme";
            claims.defaultTLSCertDuration = "1680h";
          }
        ];
        admins = [
          {
            subject = "ssh-host-provisioner";
            provisioner = "ssh-host-provisioner";
            type = "SUPER_ADMIN";
          }
        ];
        template = { };
        backdate = "1m0s";
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };

  services.nginx.virtualHosts."ca.luj" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://100.100.45.14:8444";
    };
  };

  security.acme.certs."ca.luj".server = lib.mkForce "https://100.100.45.14:8444/acme/acme/directory";

  machine.meta.probes.monitors."ca.luj - IPv4".url = lib.mkForce "https://100.100.45.14/health";
  machine.meta.probes.monitors."ca.luj - IPv6".url = lib.mkForce "https://[fd7a:115c:a1e0::e]/health";

  systemd.services."step-ca" = {
    after = [ "kanidm.service" ];
    preStart = lib.mkAfter ''
      install -m 600 -o step-ca /etc/smallstep/ca.json /run/step-ca/ca.json
      ${pkgs.replace-secret}/bin/replace-secret '@step-ca-oidc-secret@' '${config.age.secrets.step-ca-oidc-secret.path}' /run/step-ca/ca.json
      ${pkgs.replace-secret}/bin/replace-secret '@step-ca-jwk-encrypted-key@' '${config.age.secrets.step-ca-jwk-encrypted-key.path}' /run/step-ca/ca.json
    '';
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""
        "${pkgs.step-ca}/bin/step-ca /run/step-ca/ca.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
      ];
      RuntimeDirectory = "step-ca";
    };
  };

  system.stateVersion = "22.11";
}
