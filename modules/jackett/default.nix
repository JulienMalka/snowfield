{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.luj.jackett;
  port = 9117;
  host = "${cfg.subdomain}.luj";
in
{
  options.luj.jackett = {
    enable = lib.mkEnableOption "the jackett tracker indexer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "Name to serve jackett under on the VPN, without the .luj suffix.";
    };
  };

  config = lib.mkIf cfg.enable {
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
      user = "mediaserver";
      group = "mediaserver";
    };

    # Jackett answers an unauthenticated probe with 400 rather than 2xx.
    machine.meta.probes.monitors."${host} - IPv4".accepted_statuscodes = [ "400" ];
    machine.meta.probes.monitors."${host} - IPv6".accepted_statuscodes = [ "400" ];

    luj.nginx.enable = true;
    services.nginx.virtualHosts.${host}.locations."/".proxyPass = "http://localhost:${toString port}";
  };
}
