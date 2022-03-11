{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];


  luj = {
    irc.enable = true;
    mediaserver = {
      enable = true;
      tv.enable = true;
      music.enable = true;
    };
    homepage.enable = true;
    bincache = {
      enable = true;
      subdomain = "bin";
    };
    drone = {
      enable = true;
      subdomain = "ci";
    };
    zfs-mails = {
      enable = false;
      name = "lisa";
      smart.enable = false;
    };
    docs = {
      enable = true;
      nginx = {
        enable = true;
        subdomain = "docs";
      };
    };
    homer.enable = true;
    bruit = {
      enable = true;
      nginx = {
        enable = true;
        subdomain = "bruit";
      };
    };
    mailserver.enable = true;

  };


  nix.maxJobs = lib.mkDefault 4;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.fail2ban.enable = true;

  networking.hostName = "lisa";
  networking.interfaces.ens20.useDHCP = false;
  networking.interfaces.ens20.ipv4.addresses = [{ address = "212.129.40.11"; prefixLength = 32; }];
  networking.localCommands = ''
    ip r del default || ip r add default dev ens20
  '';
  networking.interfaces.ens18.useDHCP = true;
  networking.interfaces.ens19.useDHCP = false;
  networking.interfaces.ens19.ipv6.addresses = [{
    address = "2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb";
    prefixLength = 120;
  }];

  networking.nameservers = [ "10.100.0.2" ];
  networking.hostId = "fbb334ae";
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  system.stateVersion = "21.11";


  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens20";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens20 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens20 -j MASQUERADE
      '';

      privateKeyFile = "/root/wg-private";
      peers = [
        {
          allowedIPs = [ "10.100.0.2/32" ];
          publicKey = "WQoOWKT6VFn9p8vyLdI1n8tg8IRX1t7tCWXOa1zcHRU=";
        }
        {
          allowedIPs = [ "10.100.0.3/32" ];
          publicKey = "Pp4dQhhdokqYD1JBh+HLoqBbC+FEs64qzXHWfXyu2VE=";
        }
        {
          allowedIPs = [ "10.100.0.4/32" ];
          publicKey = "1d10sX645HAbXeXbvAs2zgjsoYgfg7d2UCQV1xKoY3s=";
        }
        {
          allowedIPs = [ "10.100.0.5/32" ];
          publicKey = "3BlHbLcL05UObnlIWrC/TMjZKdxrH8HTm8h0xxzAWA8=";
        }
        {
          allowedIPs = [ "10.100.0.6/32" ];
          publicKey = "ifMWTkMWpjibnthrRNPtfp2xcgqGQGng3XieVO7Lvzg=";
        }
        {
          allowedIPs = [ "10.100.0.7/32" ];
          publicKey = "TAIP4faPBx6gk1cifC6fdfIP6slo1ir+HMVKxQXBejo=";
        }
        {
          allowedIPs = [ "10.100.0.8/32" ];
          publicKey = "EmWRWnZfr60ekm4ZLdwa6gXU6V3p39p6tWOZ03dL+DA=";
        }
        {
          allowedIPs = [ "10.100.0.9/32" ];
          publicKey = "z85y4nc+7O7t2I4VqP0SAKJOD46PlkXoEPiuGOBS+SI=";
        }
        {
          allowedIPs = [ "10.100.0.10/32" ];
          publicKey = "SJ9tflQps1kssFsgVGLhqSSVKNPDspd+5xVMSu/aqk4=";
        }
      ];

    };
  };




  services.nginx.virtualHosts."jellyfin.mondon.me" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://10.100.0.4";
    };
  };

}
