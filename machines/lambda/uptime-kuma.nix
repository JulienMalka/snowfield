{
  pkgs,
  lib,
  nixosConfigurations,
  config,
  inputs,
  ...
}:
let

  probesFromConfig = lib.mkMerge (
    lib.mapAttrsToList (_: value: value.config.machine.meta.monitors) nixosConfigurations
  );
in
{

  services.uptime-kuma = {
    enable = true;
    package = pkgs.uptime-kuma-beta;
    settings = {
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
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

  age.secrets."stateless-uptime-kuma-password".file = ../../secrets/stateless-uptime-kuma-password.age;
  nixpkgs.overlays = [
    (import "${inputs.stateless-uptime-kuma}/overlay.nix")
  ];

  statelessUptimeKuma = {
    enableService = true;
    probesConfig.monitors = probesFromConfig;
    extraFlags = [
      "-s"
      "-v DEBUG"
    ];

    host = "http://localhost:${builtins.toString 3001}/";
    username = "Julien";
    passwordFile = config.age.secrets."stateless-uptime-kuma-password".path;
  };

}
