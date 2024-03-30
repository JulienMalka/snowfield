{ lib, config, ... }:
with lib;
let
  cfg = config.luj.docs;
  port = 3013;
in
{

  options.luj.docs = {

    enable = mkEnableOption "activate hedgedoc service";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.hedgedoc = {
        enable = true;
        settings = {
          inherit port;
          db = {
            dialect = "postgres";
            host = "/run/postgresql";
          };
          domain = "docs.julienmalka.me";
          protocolUseSSL = true;
          allowFreeURL = true;
          allowEmailRegister = false;
          allowAnonymous = false;
          allowAnonymousEdits = true;
          allowGravatar = true;
        };
      };
      services.postgresql = {
        ensureDatabases = [ "hedgedoc" ];
        ensureUsers = [
          {
            name = "hedgedoc";
            ensurePermissions."DATABASE hedgedoc" = "ALL PRIVILEGES";
          }
        ];
      };
    }


      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))

      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);





}
