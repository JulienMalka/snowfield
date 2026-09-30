{
  pkgs,
  inputs,
  profiles,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./uptime-kuma.nix
    ./victoria-metrics.nix
    ./grafana.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      server
      monitoring
    ];
    ips = {
      # GCP NATs 34.88.121.72 to the VM's 10.166.0.2; the IPv6 is on the VM.
      public.ipv4 = "34.88.121.72";
      public.ipv6 = "2600:1900:4150:551::";
      vpn.ipv4 = "100.100.45.13";
      vpn.ipv6 = "fd7a:115c:a1e0::d";
    };
  };

  documentation.man.generateCaches = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useNetworkd = true;
  # GCP hands out both the IPv4 and the IPv6 over DHCP. This file shadows
  # the one google-compute-config generates for eth0, so it carries the MTU.
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eth0";
    DHCP = "yes";
    linkConfig = {
      MTUBytes = "1460";
      RequiredForOnline = "routable";
    };
  };

  deployment.buildOnTarget = true;
  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  services.ntfy-sh = {
    enable = true;
    package = pkgs.unstable.ntfy-sh;
    settings = {
      listen-http = ":8081";
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      base-url = "https://notifications.julienmalka.me";
      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all";
    };
  };

  services.nginx.virtualHosts."notifications.julienmalka.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8081";
      proxyWebsockets = true;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  system.stateVersion = "22.11";
}
