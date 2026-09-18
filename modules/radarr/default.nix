{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.luj.radarr;
  port = 7878;
in
{
  options.luj.radarr = {
    enable = lib.mkEnableOption "the radarr movie manager";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "Name to serve radarr under on the VPN, without the .luj suffix.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      package = pkgs.unstable.radarr;
      # The whole stack runs as the user luj.mediaserver creates, so every
      # service reaches the same library on disk.
      user = "mediaserver";
      group = "mediaserver";
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.subdomain}.luj".locations."/".proxyPass =
      "http://localhost:${toString port}";
  };
}
