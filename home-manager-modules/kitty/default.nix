{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.kitty;
in
with lib;
{
  options.luj.programs.kitty = {
    enable = mkEnableOption "Enable SwayWM";
  };

  config = mkIf cfg.enable {

    programs.kitty = {
      enable = true;
    };
  };
}
