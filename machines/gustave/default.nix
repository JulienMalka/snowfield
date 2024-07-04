{ pkgs, ... }:

{
  imports = [
    ../../users/default.nix
    ../../users/julien.nix
    ./hardware.nix
    ./home-julien.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    routes = [
      {
        routeConfig.Metric = 500;
        routeConfig.Destination = "0.0.0.0/0";
      }
    ];
    networkConfig = {
      DHCP = "ipv4";
      Address = "2a01:e0a:de4:a0e1:eb2:aaaa::45/128";
    };
    linkConfig.RequiredForOnline = "routable";
  };

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
          wireguardPeerConfig = {
            RouteMetric = 2000;
            PublicKey = "oYsN1Qy+a7dwVOKapN5s5KJOmhSflLHZqh+GLMeNpHw=";
            AllowedIPs = [ "0.0.0.0/0" ];
            Endpoint = "[2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb]:51821";
            PersistentKeepalive = 25;
          };
        }
      ];
    };
  };
  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    addresses = [
      {
        addressConfig.Address = "10.100.45.2/24";
        addressConfig.AddPrefixRoute = false;
      }
    ];
    DHCP = "no";
    gateway = [ "10.100.45.1" ];
    networkConfig = {
      IPv6AcceptRA = false;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  services.forgejo = {
    enable = true;
  };

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
    music.enable = true;
  };
  luj.deluge.interface = "wg0";

  networking.firewall.allowedTCPPorts = [ 51820 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  system.stateVersion = "23.11";
}
