{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.luj.sonarr;
  port = 8989;
in
{
  options.luj.sonarr = {
    enable = lib.mkEnableOption "the sonarr series manager";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "Name to serve sonarr under on the VPN, without the .luj suffix.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      package = pkgs.sonarr;
      user = "mediaserver";
      group = "mediaserver";
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.subdomain}.luj".locations."/".proxyPass =
      "http://localhost:${toString port}";
  };
}
