{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.luj.programs.hyprland;
  terminal = "${pkgs.kitty}/bin/kitty";
  menu = "${pkgs.rofi-wayland}/bin/rofi -no-lazy-grab -show";
in
with lib;
{
  options.luj.programs.hyprland = {
    enable = mkEnableOption "Enable HyprLand";
  };

  config = mkIf cfg.enable
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = pkgs.hyprland;

      };

      xdg.configFile."hypr/hyprland.conf".text = ''
                exec-once = waybar & hyprpaper
                exec-once=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
                exec swayidle -w \
                  timeout 300 'swaylock -f -c 000000' \
                  timeout 600 'swaymsg "output * dpms off"' \
                  resume 'swaymsg "output * dpms on"' \
                  before-sleep 'swaylock -f -c 000000'

                exec-once = nm-applet --indicator 
                # Monitors
                monitor = eDP-1, preferred, auto, auto
      
                # Input
                input {
                  kb_layout = fr
                  follow_mouse = 1
                  touchpad {
                      natural_scroll = true
                      tap-to-click = false
                  }
                  sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                }
    
                # General
                general {
            gaps_in = 4
            gaps_out = 8
            border_size = 2
            col.active_border = rgb(11111b)
            col.inactive_border = rgb(11111b)
            cursor_inactive_timeout = 1
            layout = dwindle
        }
    
                # Misc
                misc {
                  disable_hyprland_logo = true
                  disable_splash_rendering = true
                }
    
                # Decorations
                decoration {
                      rounding = 5
                      active_opacity = 0.9
                      blur_new_optimizations = on
                      blur_size = 8
                      blur_passes = 10
                      blur = false

                                  }
    
                animations {
                  enabled = true
                }
    
                # Gestures
                gestures {
                  workspace_swipe = true
                  workspace_swipe_fingers = 4
                }
    
    
                # Variables
                $term = ${terminal}
                $browser = firefox
                $editor = nvim
                $files = nemo
                $launcher = ${menu}
    
                # Apps
                bind = SUPER, RETURN, exec, alacritty
                bind = SUPER SHIFT, E, exec, $editor
                bind = SUPER SHIFT, F, exec, $files
                bind = SUPER SHIFT, B, exec, $browser
                bind = SUPER, SPACE, exec, $launcher
                bind = SUPER, X, exec, power-menu
    
                # Function keys
                bind = ,XF86MonBrightnessUp, exec, brightnessctl s +10
                bind = ,XF86MonBrightnessDown, exec, brightnessctl s 10-
    
                # Screenshots
                bind = , Print, exec, $screenshotarea
                bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
                bind = SUPER SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output
                bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
                bind = SUPER SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen
    
                # Misc
                bind = CTRL ALT, L, exec, swaylock
    
                # Window management
                bind = SUPER, Q, killactive,
                bind = SUPER, M, exit,
                bind = SUPER, F, fullscreen,
                bind = SUPER, D, togglefloating,
                bind = SUPER, P, pseudo, # dwindle
                bind = SUPER, J, togglesplit, # dwindle
    
                # Focus
                bind = SUPER, left, movefocus, l
                bind = SUPER, right, movefocus, r
                bind = SUPER, up, movefocus, u
                bind = SUPER, down, movefocus, d
    
                # Move
                bind = SUPER SHIFT, left, movewindow, l
                bind = SUPER SHIFT, right, movewindow, r
                bind = SUPER SHIFT, up, movewindow, u
                bind = SUPER SHIFT, down, movewindow, d
    
                # Resize
                bind = SUPER CTRL, left, resizeactive, -20 0
                bind = SUPER CTRL, right, resizeactive, 20 0
                bind = SUPER CTRL, up, resizeactive, 0 -20
                bind = SUPER CTRL, down, resizeactive, 0 20
    
                # Tabbed
                bind= SUPER, g, togglegroup
                bind= SUPER, tab, changegroupactive
    
                # Special workspace
                bind = SUPER, grave, togglespecialworkspace
                bind = SUPERSHIFT, grave, movetoworkspace, special
    
                # Switch workspaces
                bind = SUPER, ampersand, workspace, 1
                bind = SUPER, eacute, workspace, 2
                bind = SUPER, quotedbl, workspace, 3 
                bind = SUPER, apostrophe, workspace, 4 
                bind = SUPER, parenleft, workspace, 5 
                bindm = SUPER, mouse:272, movewindow
                bindm = SUPER, mouse:273, resizewindow
                bind = SUPER, mouse_down, workspace, e+1
                bind = SUPER, mouse_up, workspace, e-1

                bind = SUPER SHIFT, ampersand, movetoworkspace, 1
                bind = SUPER SHIFT, eacute, movetoworkspace, 2
                bind = SUPER SHIFT, quotedbl, movetoworkspace, 3 
                bind = SUPER SHIFT, apostrophe, movetoworkspace, 4 
                bind = SUPER, parenleft, movetoworkspace, 5 

      '';
      xdg.configFile."hypr/hyprpaper.conf".text = ''
        preload = ${../../machines/macintosh/wallpaper.jpg}
        wallpaper = ,${../../machines/macintosh/wallpaper.jpg}
      '';



      home.packages = with pkgs; [ qt6.qtwayland libsForQt5.qt5.qtwayland hyprpaper swaylock swayidle ];

    };
}

