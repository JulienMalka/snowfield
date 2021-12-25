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
      users.users.nix-serve = {
        isSystemUser = true;
      };
      nix.allowedUsers = [ "nix-serve" ];
      users.users.nix-serve.group = "nix-serve";
      users.groups.nix-serve = { };

      sops.secrets.bin-cache-priv-key = {
        owner = "nix-serve";
      };

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
