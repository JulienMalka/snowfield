{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.gtk;
in
{
  options.luj.programs.gtk = {
    enable = lib.mkEnableOption "Enable gtk customizations";
  };

  config = lib.mkIf cfg.enable {
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
      platformTheme.name = "gnome";
      style.name = "adwaita-dark";
    };
  };
}
