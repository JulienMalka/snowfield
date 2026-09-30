{
  pkgs,
  lib,
  nixosConfigurations,
  config,
  inputs,
  ...
}:
let

  monitorsFromConfig = lib.mkMerge (
    lib.mapAttrsToList (_: value: value.config.machine.meta.probes.monitors) nixosConfigurations
  );

  pagesFromConfig = lib.mkMerge (
    lib.mapAttrsToList (_: value: value.config.machine.meta.probes.status_pages) nixosConfigurations
  );

in
{

  services.uptime-kuma = {
    enable = true;
    package = pkgs.unstable.uptime-kuma;
    settings = {
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  services.nginx.virtualHosts."status.julienmalka.me" = {
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  age.secrets."stateless-uptime-kuma-password".file = ./stateless-uptime-kuma-password.age;
  nixpkgs.overlays = [
    (import "${inputs.stateless-uptime-kuma}/overlay.nix")
  ];

  statelessUptimeKuma = {
    enableService = true;
    probesConfig.monitors = monitorsFromConfig;
    probesConfig.status_pages = pagesFromConfig;
    extraFlags = [
      "-s"
      "-v DEBUG"
    ];

    host = "http://localhost:${builtins.toString 3001}/";
    username = "Julien";
    passwordFile = config.age.secrets."stateless-uptime-kuma-password".path;
  };

  # At boot the deployer starts right after uptime-kuma, before it listens,
  # and fails with "unable to connect". Retry until it is up.
  systemd.services.stateless-uptime-kuma.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "15s";
  };
  systemd.services.stateless-uptime-kuma.startLimitIntervalSec = 600;
  systemd.services.stateless-uptime-kuma.startLimitBurst = 10;

}
