{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.luj.sonarr;
  port = 8989;
in
{

  options.luj.sonarr = {

    enable = mkEnableOption "activate sonarr service";

    user = mkOption {
      type = types.str;
      default = "sonarr";
      description = "User account under which Sonarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "sonarr";
      description = "Group under which Sonarr runs.";
    };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.sonarr = {
        enable = true;
        package = pkgs.unstable.sonarr;
        inherit (cfg) user group;
      };
    }

    (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))
  ]);
}
