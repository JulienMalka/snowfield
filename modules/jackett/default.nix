{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.luj.jackett;
  port = 9117;
in
{

  options.luj.jackett = {
    enable = mkEnableOption "activate jackett service";

    user = mkOption {
      type = types.str;
      default = "jackett";
      description = "User account under which Jackett runs.";
    };

    group = mkOption {
      type = types.str;
      default = "jackett";
      description = "Group under which Jackett runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
      services.jackett = {
        enable = true;
        package = pkgs.unstable.jackett;
        inherit (cfg) user group;
      };

    }

      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);




}
