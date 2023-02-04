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
        name = "Catppuccin-Macchiato-Standard-Pink-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          variant = "macchiato";
        };
      };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  };
}
