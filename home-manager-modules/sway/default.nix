{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.sway;
  modifier = cfg.modifier;
  terminal = "kitty";
in
with lib;
{
  options.luj.programs.sway = {
    enable = mkEnableOption "Enable SwayWM";
    modifier = mkOption {
      type = lib.types.str;
      default = "Mod1";
    };
    background = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
      config = {
        terminal = terminal;
        output =
          {
            DP-6 = {
              bg = builtins.toString cfg.background + " fill";
            };

            DP-7 = {
              bg = builtins.toString cfg.background + " fill";
              pos = "0 0";
            };

          };
        modifier = cfg.modifier;
        input = {
          "*" = {
            xkb_layout = "fr";
          };
        };

        gaps = {
          right = 2;
          left = 2;
          top = 0;
          bottom = 0;
          inner = 1;
        };

        bars = [ ];
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
          "${modifier}+w" = "exec swaylock";
        };
      };
      extraConfig = ''
        set $laptop eDP-1
        corner_radius 8
        default_dim_inactive 0.2
        default_border none
        default_floating_border none
        bindswitch lid:on output $laptop disable
        bindswitch lid:off output $laptop enable
      '';
      extraOptions = [ "--unsupported-gpu" ];
    };

    programs.swaylock =
      {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          screenshots = true;
          clock = true;
          indicator = true;
          indicator-radius = 200;
          indicator-thickness = 20;
          grace = 0;
          grace-no-mouse = true;
          grace-no-touch = true;
          line-uses-ring = false;
          ignore-empty-password = true;
          show-failed-attempts = false;

          font = "Fira Code";
          timestr = "%H:%M";
          datestr = "";
          effect-blur = "8x5";
          effect-vignette = "0.5:0.5";
          color = "00000000";

        };

      };

  };
}
