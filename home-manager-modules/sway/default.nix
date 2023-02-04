{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.sway;
  modifier = "Mod4";
  terminal = "alacritty";
in
with lib;
{
  options.luj.programs.sway = {
    enable = mkEnableOption "Enable SwayWM";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        terminal = terminal;
        modifier = modifier;
        input = {
          "*" = {
            xkb_layout = "fr";
            xkb_variant = "mac";
          };
        };

        gaps = {
          right = 2;
          left = 2;
          top = 2;
          bottom = 2;
          inner = 7;
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+ampersand" = "workspace 1";
          "${modifier}+eacute" = "workspace 2";
          "${modifier}+quotedbl" = "workspace 3";
          "${modifier}+apostrophe" = "workspace 4";
          "${modifier}+parenleft" = "workspace 5";
          "${modifier}+egrave" = "workspace 6";
          "${modifier}+minus" = "workspace 7";
          "${modifier}+underscore" = "workspace 8";
          "${modifier}+ccedilla" = "workspace 9";
          "${modifier}+agrave" = "workspace 10";

          "${modifier}+Shift+ampersand" = "move container to workspace 1";
          "${modifier}+Shift+eacute" = "move container to workspace 2";
          "${modifier}+Shift+quotedbl" = "move container to workspace 3";
          "${modifier}+Shift+apostrophe" = "move container to workspace 4";
          "${modifier}+Shift+parenleft" = "move container to workspace 5";
          "${modifier}+Shift+egrave" = "move container to workspace 6";
          "${modifier}+Shift+minus" = "move container to workspace 7";
          "${modifier}+Shift+underscore" = "move container to workspace 8";
          "${modifier}+Shift+ccedilla" = "move container to workspace 9";
          "${modifier}+Shift+agrave" = "move container to workspace 10";

          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";


          "${modifier}+q" = "kill";
          "${modifier}+space" = "exec rofi -show run";
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+f" = "fullscreen toggle";

          "XF86MonBrightnessUp" = "exec brightnessctl s +10";
          "XF86MonBrightnessDown" = "exec brightnessctl s 10-";
        };
      };
    };

    services.swayidle.enable = true;


  };
}
