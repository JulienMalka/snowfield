{ lib, config, ... }:
with lib;
let
  cfg = config.luj.nginx;
in
{

  options.luj.nginx = {
    enable = mkEnableOption "activate nginx service";
    email = mkOption {
      type = types.str;
      default = "julien@malka.sh";
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    security.acme.defaults.email = "${cfg.email}";
    security.acme.acceptTerms = true;
    users.groups.nginx = {
      name = "nginx";
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
        server_names_hash_bucket_size 128;
      '';
    };

    services.nginx.virtualHosts."404.julienmalka.me" = {
      default = true;
      locations."/" = {
        root = "${./404}";
      };
    };

    machine.meta.zones."julienmalka.me".subdomains."404" = lib.mkForce { };

  };
}
