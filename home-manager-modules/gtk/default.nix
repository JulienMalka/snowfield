{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.gtk;
in
with lib;
{
  options.luj.programs.gtk = {
    enable = mkEnableOption "Enable gtk customizations";
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  };
}
