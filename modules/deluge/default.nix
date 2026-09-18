{
  lib,
  config,
  ...
}:
let
  cfg = config.luj.deluge;
  port = 8112;
  user = "mediaserver";
in
{
  options.luj.deluge = {
    enable = lib.mkEnableOption "the deluge torrent client";

    interface = lib.mkOption {
      type = lib.types.str;
      description = "Interface deluge will use.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "Name to serve the deluge web UI under, without the .luj suffix.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.deluge-webui-password = {
      owner = user;
      file = ./deluge-webui-password.age;
    };

    services.deluge = {
      enable = true;
      inherit user;
      group = user;
      openFirewall = true;
      declarative = true;
      authFile = "/run/agenix/deluge-webui-password";
      web.enable = true;
      config = {
        download_location = "${config.users.users.${user}.home}/downloads/";
        allow_remote = true;
        outgoing_interface = cfg.interface;
        listen_interface = cfg.interface;
      };
    };

    luj.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.subdomain}.luj".locations."/".proxyPass =
      "http://localhost:${toString port}";
  };
}
