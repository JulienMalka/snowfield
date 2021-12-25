{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.luj.bincache;
  port = 5000;
in
with lib;
{
  options.luj.bincache = {
    enable = mkEnableOption "Enable nix bincache";
    subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable
    {
      sops.secrets.bin-cache-priv-key = {};

      services.nix-serve = {
        enable = true;
        secretKeyFile = "/run/secrets/bin-cache-priv-key";
        port = port;
      };
      
      luj.nginx.enable = true;
      services.nginx.virtualHosts."${cfg.subdomain}.julienmalka.me" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
        };
      };
    };
}
