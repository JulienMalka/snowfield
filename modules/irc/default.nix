{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.irc;
  port = 9117;
in
{

  options.luj.irc = {
    enable = mkEnableOption "activate weechat service";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable (
    mkMerge [{
    services.weechat.enable = true; 
    }

      (mkIf cfg.nginx.enable (mkPrivateSubdomain cfg.nginx.subdomain port))

      
      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);
 



}
