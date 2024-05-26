{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  deployment.buildOnTarget = true;

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
