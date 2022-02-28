{ lib, pkgs, inputs, config, ... }:
with lib;
let
  cfg = config.luj.homepage;
in
{
  options.luj.homepage = {
    enable = mkEnableOption "enable homepage";
  };

  config = mkIf cfg.enable
    {
      luj.nginx.enable = true;
      services.nginx.virtualHosts."julienmalka.me" = {
        enableACME = true;
        forceSSL = true;
        root = inputs.homepage;
      };

      services.nginx.virtualHosts."www.julienmalka.me" = {
        enableACME = true;
        forceSSL = true;
        root = inputs.homepage;
      };

      nix.gcRoots = [ inputs.homepage ];

    };
}
