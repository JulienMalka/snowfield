{
  lib,
  config,
  ...
}:
let
  cfg = config.luj.lidarr;
  port = 8686;
in
{
  options.luj.lidarr = {
    enable = lib.mkEnableOption "the lidarr music manager";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "Name to serve lidarr under on the VPN, without the .luj suffix.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.lidarr = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.subdomain}.luj".locations."/".proxyPass =
      "http://localhost:${toString port}";
  };
}
