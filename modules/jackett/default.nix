{
  lib,
  config,
  pkgs,
  ...
}:
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
    nginx.subdomain = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.jackett = {
        enable = true;
        # unstable version to have updated torrent list
        package = pkgs.unstable.jackett.overrideAttrs (
          _: _: {
            doCheck = false;
            postInstall = ''
              cp ${./ygg-api.yml} $out/lib/jackett/Definitions/ygg-api.yml
            '';
          }
        );
        inherit (cfg) user group;
      };
    }

    (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))
  ]);
}
