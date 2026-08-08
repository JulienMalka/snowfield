{
  config,
  pkgs,
  lib,
  ...
}:
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
      gtk4.theme = config.gtk.theme;
    };
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };
  };
}
