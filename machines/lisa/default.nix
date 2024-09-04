{ modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ips = {
      public.ipv4 = "212.129.40.11";
      vpn.ipv4 = "100.100.45.12";
      public.ipv6 = "2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb";
      vpn.ipv6 = "fd7a:115c:a1e0::c";
    };

  };

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

  deployment.tags = [ "server" ];

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
