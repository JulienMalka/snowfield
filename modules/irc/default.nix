{
  lib,
  config,
  ...
}:
let
  cfg = config.luj.irc;
  port = 8349;
  upstream = "http://localhost:${toString port}";
in
{
  options.luj.irc = {
    enable = lib.mkEnableOption "the thelounge IRC client";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name to serve thelounge under. It is published both publicly and on the
        VPN, so this is the prefix of two host names.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.thelounge = {
      inherit port;
      enable = true;
      public = false;
      extraConfig.fileUpload.enable = true;
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts = {
      "${cfg.subdomain}.julienmalka.me".locations."/".proxyPass = upstream;
      "${cfg.subdomain}.luj".locations."/".proxyPass = upstream;
    };
  };
}
