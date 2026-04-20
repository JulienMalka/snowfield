{ pkgs, ... }:

let
  port = 8001;
in
{
  services.windmill = {
    enable = true;
    package = pkgs.unstable.windmill;
    baseUrl = "https://workflows.luj.fr";
    serverPort = port;
    database.createLocally = true;
  };

  systemd.services.windmill-worker.path = with pkgs; [
    git
    gh
    nix
    nixfmt-rfc-style
    bash
  ];

  systemd.services.windmill-worker-native.path = with pkgs; [
    git
    gh
    nix
    nixfmt-rfc-style
    bash
  ];

  services.nginx.virtualHosts."workflows.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
