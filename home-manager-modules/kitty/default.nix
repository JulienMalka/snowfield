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
      extraConfig = ''
                font_family Noto Color Emoji Regular
        font_family Fira Code Regular
        bold_font Fira Code Retina
        font_features FiraCode-Regular +zero +ss01 +ss02 +ss03 +ss04 +ss05 +cv31
        font_features FiraCode-Retina +zero +ss01 +ss02 +ss03 +ss04 +ss05 +cv31
        font_size 10.0
        shell_integration no-cursor
        cursor_shape block
        cursor_blink_interval 0

        # Tab Management
        tab_bar_edge top
        tab_bar_margin_height 0.0 4.0
        tab_bar_style powerline
        tab_bar_min_tabs 2
        tab_title_template "{index} {tab.active_exe}"

        map ctrl+shift+1 goto_tab 1
        map ctrl+shift+2 goto_tab 2
        map ctrl+shift+3 goto_tab 3
        map ctrl+shift+4 goto_tab 4

        # The basic colors
        foreground              #CDD6F4
        background              #11111B
        selection_foreground    #11111B
        selection_background    #F5E0DC

        # Cursor colors
        cursor                  #F5E0DC
        cursor_text_color       #11111B

        # URL underline color when hovering with mouse
        url_color               #F5E0DC

        # Kitty window border colors
        active_border_color     #B4BEFE
        inactive_border_color   #6C7086
        bell_border_color       #F9E2AF

        # OS Window titlebar colors
        wayland_titlebar_color system
        macos_titlebar_color system

        # Tab bar colors
        active_tab_foreground   #11111B
        active_tab_background   #CBA6F7
        inactive_tab_foreground #CDD6F4
        inactive_tab_background #181825
        tab_bar_background      #11111B

        # Colors for marks (marked text in the terminal)
        mark1_foreground #11111B
        mark1_background #B4BEFE
        mark2_foreground #11111B
        mark2_background #CBA6F7
        mark3_foreground #11111B
        mark3_background #74C7EC

        # The 16 terminal colors

        # black
        color0 #45475A
        color8 #585B70

        # red
        color1 #F38BA8
        color9 #F38BA8

        # green
        color2  #A6E3A1
        color10 #A6E3A1

        # yellow
        color3  #F9E2AF
        color11 #F9E2AF

        # blue
        color4  #89B4FA
        color12 #89B4FA

        # magenta
        color5  #F5C2E7
        color13 #F5C2E7

        # cyan
        color6  #94E2D5
        color14 #94E2D5

        # white
        color7  #BAC2DE
        color15 #A6ADC8

      '';
    };
  };
}
