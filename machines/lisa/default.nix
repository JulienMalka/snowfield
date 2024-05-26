{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware.nix
    ./home-julien.nix
  ];

  luj = {
    docs = {
      enable = true;
      nginx = {
        enable = true;
        subdomain = "docs";
      };
    };
    mailserver.enable = true;
  };

  services.fail2ban.enable = true;

  networking.hostId = "fbb334ae";

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    networks = {
      "10-wan" = {
        matchConfig.Name = "ens20";
        address = [ "212.129.40.11/32" ];
        routes = [
          {
            routeConfig = {
              Gateway = "212.129.40.11";
              Destination = "0.0.0.0/0";
            };
          }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
      "20-wan" = {
        matchConfig.Name = "ens18";
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "routable";
      };
      wg0 = {
        matchConfig.Name = "wg0";
        address = [
          "10.100.45.1/24"
          "fc00::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };
    };

    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = "/srv/wg-private";
          ListenPort = 51821;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "axigTezuClSoQlxWvpdzXKXUDjrrQlswE50ox0uDLR0=";
              AllowedIPs = [ "10.100.45.2/32" ];
            };
          }
        ];
      };
    };
  };

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  networking.firewall.allowedTCPPorts = [
    51820
    51821
  ];
  networking.firewall.allowedUDPPorts = [
    51820
    51821
  ];

  system.stateVersion = "21.11";
}
