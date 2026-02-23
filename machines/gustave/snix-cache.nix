{
  config,
  pkgs,
  lib,
  ...
}:
let
  toml = pkgs.formats.toml { };
  endpointsToml = toml.generate "endpoints.toml" config.services.snix-cache.endpointsConfig;
in
{
  services.snix-cache = {
    enable = true;
    host = "cache.luj.fr";
    caches.snowfield = {
      maxBodySize = "50G";
      uploadPasswordFile = config.age.secrets.snix-cache-upload-htpasswd.path;
      signing = {
        keyFile = config.age.secrets.snix-cache-signing-key.path;
        publicKey = "cache.luj.fr-1:C4ZpEGda4niPPcPtSMTzfiz1OLl8a+HzSdq1hUhAh6w=";
      };
    };
  };

  # Override ExecStart to use our secret composition TOML (contains S3 credentials)
  systemd.services.snix-cache.serviceConfig = {
    LoadCredential = [
      "composition.toml:${config.age.secrets.snix-cache-composition.path}"
    ];
    ExecStart = lib.mkForce "${lib.getExe config.services.snix-cache.package} --endpoints-config ${endpointsToml} --store-composition \${CREDENTIALS_DIRECTORY}/composition.toml";
  };

  # Resolve s3.luj.fr directly to biblios's IPv6, bypassing the router's
  # hairpin NAT (gustave and biblios share the same public IPv4).
  networking.extraHosts = ''
    ${lib.snowfield.biblios.ips.public.ipv6} s3.luj.fr
  '';

  services.nginx.virtualHosts."cache.luj.fr" = {
    enableACME = true;
    forceSSL = true;
  };

  age.secrets.snix-cache-signing-key.file = ./snix-cache-signing-key.age;
  age.secrets.snix-cache-upload-htpasswd = {
    file = ./snix-cache-upload-htpasswd.age;
    owner = "nginx";
    group = "nginx";
  };
  age.secrets.snix-cache-composition.file = ./snix-cache-composition.age;
}
