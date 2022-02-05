{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.flaresolverr;
in
{

  options.luj.flaresolverr = {
    enable = mkEnableOption "activate flaresolverr service";
  };

  config = mkIf cfg.enable {
    systemd.services.flaresolverr = {
      description = "Flaresolverr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
        Restart = "on-failure";
      };
    };
  };

}
