{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "aarch64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ipv4 = {
      public = "141.145.197.219";
      vpn = "100.100.45.13";
    };
    ipv6 = {
      public = "2603:c027:c001:89aa:aad9:34b3:f3c9:924f";
      vpn = "fd7a:115c:a1e0::d";
    };

  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useNetworkd = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp0s3";
    DHCP = "ipv4";
    addresses = [ { addressConfig.Address = "2603:c027:c001:89aa:aad9:34b3:f3c9:924f"; } ];
    linkConfig.RequiredForOnline = "routable";
  };

  deployment.buildOnTarget = true;
  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  services.uptime-kuma = {
    enable = true;
    package = pkgs.unstable.uptime-kuma;
    settings = {
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  services.ntfy-sh = {
    enable = true;
    package = pkgs.unstable.ntfy-sh;
    settings = {
      listen-http = ":8081";
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      base-url = "https://notifications.julienmalka.me";
      auth-file = "/srv/ntfy/user.db";
      auth-default-access = "deny-all";
    };
  };

  services.nginx.virtualHosts."status.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."uptime.luj".server = "https://ca.luj/acme/acme/directory";

  services.nginx.virtualHosts."uptime.luj" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."notifications.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
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
