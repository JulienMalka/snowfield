{ lib, config, ... }:
with lib;
let
  cfg = config.luj.deluge;
  port = 8112;
in
{

  options.luj.deluge = {
    enable = mkEnableOption "activate deluge service";

    user = mkOption {
      type = types.str;
      default = "deluge";
      description = "User account under which deluge runs.";
    };

    group = mkOption {
      type = types.str;
      default = "deluge";
      description = "Group under which deluge runs.";
    };

    interface = mkOption {
      type = types.str;
      description = "Interface deluge will use.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable (mkMerge [
    {

      age.secrets.deluge-webui-password = {
        owner = cfg.user;
        file = ./deluge-webui-password.age;
      };

      services.deluge = {
        enable = true;
        inherit (cfg) user group;
        openFirewall = true;
        declarative = true;
        authFile = "/run/agenix/deluge-webui-password";
        web.enable = true;
        config = {
          download_location = "${config.users.users.${cfg.user}.home}/downloads/";
          allow_remote = true;
          outgoing_interface = cfg.interface;
          listen_interface = cfg.interface;
        };
      };
    }

    (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))
  ]);
}
