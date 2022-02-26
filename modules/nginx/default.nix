{ lib, pkgs, config, ... }:
with lib;
let cfg = config.luj.nginx;
in
{

  options.luj.nginx = {
    enable = mkEnableOption "activate nginx service";
    email = mkOption {
      type = types.str;
      default = "julien.malka@me.com";
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme.email = "${cfg.email}";
    security.acme.acceptTerms = true;
    users.groups.nginx = { name = "nginx"; };

    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      clientMaxBodySize = "128m";

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




  };
}
