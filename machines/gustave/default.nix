{
  pkgs,
  inputs,
  profiles,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./nsd.nix
    ./borg.nix
    # Performance is not as good as we expected, wait for pages v3
    #    ./pages.nix
    ./readeck.nix
    ./plausible.nix
    ./nextcloud.nix
    ./glance.nix
    ./syncthing.nix
    ./artiflakery.nix
  ];

  users.users.julien.linger = true;

  services.backup.includes = [ "/home/julien/Maildir" ];

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

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
      local.ipv4 = "192.168.0.90";
      vpn.ipv4 = "100.100.45.24";
      public.ipv6 = "2a01:e0a:de4:a0e1:eb2:aaaa::45";
      vpn.ipv6 = "fd7a:115c:a1e0::18";
    };

  };

  luj.docs = {
    enable = true;
    nginx.enable = true;
    nginx.subdomain = "docs";
  };

  security.polkit.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.fuse.userAllowOther = true;

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];

  systemd.network.netdevs = {
    "20-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = "/srv/wg-private";
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          PublicKey = "oYsN1Qy+a7dwVOKapN5s5KJOmhSflLHZqh+GLMeNpHw=";
          AllowedIPs = [ "0.0.0.0/0" ];
          Endpoint = "[${lib.snowfield.akhaten.ips.public.ipv6}]:51821";
          PersistentKeepalive = 25;
        }
      ];
    };
  };
  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    addresses = [
      {
        Address = "10.100.45.2/24";
        AddPrefixRoute = false;
      }
    ];
    routes = [
      {
        Gateway = "10.100.45.1";
        Destination = "10.100.45.0/24";
      }
    ];
    DHCP = "no";
    networkConfig = {
      IPv6AcceptRA = false;
    };
  };

  services.forgejo = {
    enable = true;
    package = pkgs.unstable.forgejo;
    database.type = "postgres";
    settings = {
      server = {
        ROOT_URL = "https://git.luj.fr/";
        LANDING_PAGE = "luj";
      };
      #openid.ENABLE_OPENID_SIGNIN = true;
      openid.ENABLE_OPENID_SIGNUP = true;
      oauth2_client.REGISTER_EMAIL_CONFIRM = false;
      oauth2_client.ENABLE_AUTO_REGISTRATION = true;
      oauth2_client.UPDATE_AVATAR = true;
      oauth2_client.ACCOUNT_LINKING = "auto";
      service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
    };
  };

  services.openssh.ports = [ 22 ];

  services.nginx.virtualHosts."git.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
      "/srv"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  fileSystems."/srv".neededForBoot = true;

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  luj.irc = {
    enable = true;
    nginx = {
      enable = true;
      subdomain = "irc";
    };
  };

  luj.homepage.enable = true;
  luj.mediaserver = {
    enable = true;
    tv.enable = true;
    music.enable = false;
  };
  luj.deluge.interface = "wg0";

  networking.firewall.allowedTCPPorts = [ 51820 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.roundcube = {
    enable = true;
    plugins = [
      "managesieve"
    ];
    hostName = "webmail.luj.fr";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://mail.luj.fr";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['imap_host'] = 'ssl://mail.luj.fr';
    '';
  };

  system.stateVersion = "23.11";
}
