{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.kitty;
in
with lib;
{
  options.luj.programs.kitty = {
    enable = mkEnableOption "Enable Kitty";
  };

  config = mkIf cfg.enable {

    programs.kitty = {
      enable = true;
      settings = {
        wayland_titlebar_color = "background";
        shell_integration = "no-cursor";
        window_padding_width = 3;
        font_size = 10;
        confirm_os_window_close = 0;
      };
      font = {
        name = "FiraCode Nerd Font Mono Reg";
        package = with pkgs; (nerdfonts.override { fonts = [ "FiraCode" ]; });
      };
      themeFile = "Catppuccin-Mocha";

    };
  };
}
