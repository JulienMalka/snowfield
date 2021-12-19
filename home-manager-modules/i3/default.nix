{ config, pkgs, lib, ... }:
let
  cfg = config.luj.i3;
in with lib;
{
  options.luj.i3 = {
    enable = mkEnableOption "activate i3";
  };

  config = mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    xdg.configFile."i3/config".source = lib.mkForce ./config;

  };
}
