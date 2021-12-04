{ lib, pkgs, config, ... }:
with lib;
let cfg = config.luj.nginx;
in {

  options.luj.nginx = {
    enable = mkEnableOption "activate nginx service";
    email = mkOption {
      type = types.str;
      default = "julien.malka@me.com";
    };
  };

  config = mkIf cfg.enable {

    security.acme.email = "${cfg.email}";
    security.acme.acceptTerms = true;

    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      clientMaxBodySize = "128m";

      commonHttpConfig = ''
        server_names_hash_bucket_size 128;
      '';
    };

  };
}
