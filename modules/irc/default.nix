{ lib, config, ... }:
with lib;
let
  cfg = config.luj.irc;
  port = 9000;
in
{

  options.luj.irc = {
    enable = mkEnableOption "activate irc service";

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.thelounge = {
        enable = true;
        public = false;
        extraConfig.fileUpload.enable = true;
      };

    }

    (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))
    (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))
  ]);

}
