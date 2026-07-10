{
  pkgs,
  lib,
  config,
  ...
}:

let
  port = 8001;

  remoteWorkerHosts = [
    lib.snowfield.epyc-container.ips.vpn.ipv4
  ];

  workerPath = with pkgs; [
    python312
    git
    gh
    nix
    nixfmt-rfc-style
    nixpkgs-review
    bash
    bubblewrap
  ];

  staticUserOverrides = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "windmill";
    Group = lib.mkForce "windmill";
  };
in
{
  users.users.windmill = {
    isSystemUser = true;
    group = "windmill";
    home = "/var/lib/windmill-worker";
    createHome = false;
  };
  users.groups.windmill = { };

  systemd.tmpfiles.rules = [
    "Z /var/lib/windmill-worker - windmill windmill - -"
  ];

  services.windmill = {
    enable = true;
    package = pkgs.unstable.windmill;
    baseUrl = "https://workflows.luj.fr";
    serverPort = port;
    database.createLocally = true;
  };

  systemd.services = {
    windmill-server = {
      environment.ZOMBIE_JOB_TIMEOUT = "3600";
      serviceConfig = staticUserOverrides;
    };
    windmill-worker.enable = false;
    windmill-worker-native = {
      path = workerPath;
      serviceConfig = staticUserOverrides;
    };
  };

  services.postgresql = {
    enableTCPIP = true;
    settings.listen_addresses = lib.mkForce "localhost,${config.machine.meta.ips.vpn.ipv4}";
    authentication = lib.mkAfter (
      lib.concatMapStringsSep "\n" (ip: "host windmill windmill ${ip}/32 trust") remoteWorkerHosts
    );
  };

  systemd.services.postgresql = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5432 ];

  services.nginx.virtualHosts."workflows.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
