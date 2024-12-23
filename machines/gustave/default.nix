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
    ./pages.nix
    ./readeck.nix
    ./plausible.nix
    ./nextcloud.nix
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

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
    settings = {
      server = {
        ROOT_URL = "https://git.luj.fr/";
        LANDING_PAGE = "luj";
      };
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

  system.stateVersion = "23.11";
}
