{ lib, config, ... }:
with lib;
let
  cfg = config.luj.lidarr;
  port = 8686;
in
{

  options.luj.lidarr = {

    enable = mkEnableOption "activate lidarr service";

    user = mkOption {
      type = types.str;
      default = "lidarr";
      description = "User account under which Lidarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "lidarr";
      description = "Group under which Lidarr runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.lidarr = {
        enable = true;
        inherit (cfg) user group;
      };
    }


      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);




}
