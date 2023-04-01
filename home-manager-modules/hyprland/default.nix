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

      home.packages = [ pkgs.hyprpaper ];

      xdg.configFile."hypr/hyprland.conf".text = ''
                exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user start hyprland-session.target
                exec-once = waybar & hyprpaper
                # Monitors
                monitor = eDP-1, preferred, auto, auto
    
                # Input
                input {
                  kb_layout = fr
                  kb_variant = mac
                  follow_mouse = 1
                  touchpad {
                      natural_scroll = true
                      tap-to-click = true
                  }
                  sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                }
    
                # General
                general {
            gaps_in = 7.5
            gaps_out = 15
            border_size = 2
            col.active_border = rgb(11111b)
            col.inactive_border = rgb(11111b)
            cursor_inactive_timeout = 1
            layout = master
        }
    
                # Misc
                misc {
                  disable_hyprland_logo = true
                  disable_splash_rendering = true
                }
    
                # Decorations
                decoration {
                  # Opacity
                  active_opacity = 1.0
                  inactive_opacity = 1.0
    
                  # Blur
                  blur = false
                  blur_size = 10
                  blur_passes = 4
                  blur_new_optimizations = true
    
                  # Shadow
                  drop_shadow = true
                  shadow_ignore_window = true
                  shadow_offset = 2 2
                  shadow_range = 4
                  shadow_render_power = 2
                  col.shadow = 0x66000000
                }
    
                # Blurring layerSurfaces
                blurls = gtk-layer-shell
                blurls = lockscreen
    
                # Animations
                animations {
                  enabled = true
    
                  # bezier curve
                  bezier = overshot, 0.05, 0.9, 0.1, 1.05
                  bezier = smoothOut, 0.36, 0, 0.66, -0.56
                  bezier = smoothIn, 0.25, 1, 0.5, 1
    
                  # animation list
                  animation = windows, 1, 5, overshot, slide
                  animation = windowsOut, 1, 4, smoothOut, slide
                  animation = windowsMove, 1, 4, default
                  animation = border, 1, 10, default
                  animation = fade, 1, 10, smoothIn
                  animation = fadeDim, 1, 10, smoothIn
                  animation = workspaces, 1, 6, overshot, slidevert
                }
    
                # Gestures
                gestures {
                  workspace_swipe = true
                  workspace_swipe_fingers = 3
                }
    
                # Layouts
                dwindle {
                  no_gaps_when_only = true
                  pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                  preserve_split = true # you probably want this
                }
    
                # Window rules
                windowrule = float, file_progress
                windowrule = float, confirm
                windowrule = float, dialog
                windowrule = float, download
                windowrule = float, notification
                windowrule = float, error
                windowrule = float, splash
                windowrule = float, confirmreset
                windowrule = float, title:Open File
                windowrule = float, title:branchdialog
                windowrule = float, zoom
                windowrule = float, vlc
                windowrule = float, Lxappearance
                windowrule = float, ncmpcpp
                windowrule = float, Rofi
                windowrule = animation none, Rofi
                windowrule = float, viewnior
                windowrule = float, pavucontrol-qt
                windowrule = float, gucharmap
                windowrule = float, gnome-font
                windowrule = float, org.gnome.Settings
                windowrule = float, file-roller
                windowrule = float, nautilus
                windowrule = float, nemo
                windowrule = float, thunar
                windowrule = float, wdisplays
                windowrule = fullscreen, wlogout
                windowrule = float, title:wlogout
                windowrule = fullscreen, title:wlogout
                windowrule = float, pavucontrol-qt
                windowrule = float, keepassxc
                windowrule = idleinhibit focus, mpv
                windowrule = idleinhibit fullscreen, firefox
                windowrule = float, title:^(Media viewer)$
                windowrule = float, title:^(Transmission)$
                windowrule = float, title:^(Volume Control)$
                windowrule = float, title:^(Picture-in-Picture)$
                windowrule = float, title:^(Firefox — Sharing Indicator)$
                windowrule = move 0 0, title:^(Firefox — Sharing Indicator)$
                windowrule = size 800 600, title:^(Volume Control)$
                windowrule = move 75 44%, title:^(Volume Control)$
    
                # Variables
                $term = ${terminal}
                $browser = firefox
                $editor = nvim
                $files = nemo
                $launcher = ${menu}
    
                # Apps
                bind = SUPER, RETURN, exec, MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330 kitty
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
                bind = SUPER, quotedbl, workspace, 
                bindm = SUPER, mouse:272, movewindow
                bindm = SUPER, mouse:273, resizewindow
                bind = SUPER, mouse_down, workspace, e+1
                bind = SUPER, mouse_up, workspace, e-1
      '';
      xdg.configFile."hypr/hyprpaper.conf".text = ''
        preload = ${../../machines/macintosh/wallpaper.jpg}
        wallpaper = ,${../../machines/macintosh/wallpaper.jpg}
      '';

    };
}

