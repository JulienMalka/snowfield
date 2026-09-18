{
  lib,
  config,
  ...
}:
let
  cfg = config.luj.jellyfin;
  port = 8096;
  upstream = "http://localhost:${toString port}";
in
{
  options.luj.jellyfin = {
    enable = lib.mkEnableOption "the jellyfin media server";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name to serve jellyfin under. It is published both publicly and on the
        VPN, so this is the prefix of two host names.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts = {
      "${cfg.subdomain}.julienmalka.me".locations."/".proxyPass = upstream;
      "${cfg.subdomain}.luj".locations."/".proxyPass = upstream;
    };
  };
}
