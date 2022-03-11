{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.irc;
  port = 2042;
in
{

  options.luj.irc = {
    enable = mkEnableOption "activate weechat service";
  };

  config = mkIf cfg.enable {

    services.weechat.enable = true;
    services.nginx.virtualHosts."irc.julienmalka.me" = {
      forceSSL = true;
      enableACME = true;
      locations."^~ /weechat" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}";
        proxyWebsockets = true;
      };
      locations."/" = {
        root = pkgs.glowing-bear;
      };
    };

  };
}
    



