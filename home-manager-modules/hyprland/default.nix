{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.hyprland;
  terminal = "${pkgs.kitty}/bin/kitty";
  menu = "${pkgs.rofi-wayland}/bin/rofi -no-lazy-grab -show drun";
in
with lib;
{
  options.luj.programs.hyprland = {
    enable = mkEnableOption "Enable HyprLand";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      systemd = {
        enable = true;
        variables = [ "WLR_NO_HARDWARE_CURSORS=1" ];
      };
      settings = {
        # Variables
        "$mod" = "ALT_L";
        "$term" = terminal;
        "$launcher" = menu;

        general = {
          gaps_in = "6";
          gaps_out = "10";
        };
        input = {
          kb_layout = "fr";
          follow_mouse = 1;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        decoration = {
          rounding = 6;
        };
        animations.enabled = true;

        xwayland = {
          force_zero_scaling = true;
        };

        workspace = [
          "1,monitor:DP-3"
          "2,monitor:HDM1-A-1"
        ];

        exec = [ "hyprpaper" ];

        env = [
          "LIBVA_DRIVER_NAME, nvidia"
          "WLR_NO_HARDWARE_CURSORS, 1"
          "WLR_DRM_DEVICES,/home/julien/.config/hypr/card"
        ];

        monitor = [
          "DP-3, 2560x1440@60, 0x0, 1"
          "HDM1-A-1, 2560x1440@60, 2560x0, 1"
        ];

        bind = [
          "$mod, RETURN, exec, kitty"
          "$mod, SPACE, exec, $launcher"
          "$mod, w, exec, swaylock"

          # Window management
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          # Focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          # Move
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Switch workspaces
          "$mod, code:10, workspace, 1"
          "$mod, code:11, workspace, 2"
          "$mod, code:12, workspace, 3"
          "$mod, code:13, workspace, 4"
          "$mod, code:14, workspace, 5"
          "$mod, code:15, workspace, 6"
          "$mod, code:16, workspace, 7"
          "$mod, code:17, workspace, 8"
          "$mod, code:18, workspace, 9"
          "$mod, code:19, workspace, 10"

          "$mod SHIFT, code:10, movetoworkspace, 1"
          "$mod SHIFT, code:11, movetoworkspace, 2"
          "$mod SHIFT, code:12, movetoworkspace, 3"
          "$mod SHIFT, code:13, movetoworkspace, 4"
          "$mod SHIFT, code:14, movetoworkspace, 5"
          "$mod SHIFT, code:15, movetoworkspace, 6"
          "$mod SHIFT, code:16, movetoworkspace, 7"
          "$mod SHIFT, code:17, movetoworkspace, 8"
          "$mod SHIFT, code:18, movetoworkspace, 9"
          "$mod SHIFT, code:19, movetoworkspace, 10"

        ];

      };

    };

    xdg.configFile."hypr/hyprpaper.conf".text = ''
      preload = ${../../machines/x2100/wallpaper.jpg}
      wallpaper = ,${../../machines/x2100/wallpaper.jpg}
    '';

    services.swayidle = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock --config /home/julien/.config/swaylock/config";
        }
      ];
    };

    programs.swaylock = {
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

    home.packages = with pkgs; [
      qt6.qtwayland
      libsForQt5.qt5.qtwayland
      hyprpaper
    ];

  };
}
