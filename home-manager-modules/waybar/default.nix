{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.waybar;
in
with lib;
{
  options.luj.programs.waybar = {
    enable = mkEnableOption "Enable waybar";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          modules-left = [ "custom/nixos" "wlr/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "backlight" "network" "battery" ];
          "custom/nixos" = {
            format = " ❄ ";
            tooltip = false;
          };
          "wlr/workspaces" = {
            format = "{name}";
            tooltip = false;
            all-outputs = true;
          };
          "clock" = { };
          "backlight" = {
            device = "intel_backlight";
            format = "<span color='#cba6f7'>{icon}</span> {percent}%";
            format-icons = [ "" "" "" "" "" "" "" "" "" ];
          };
          "pulseaudio" = {
            format = "<span color='#cba6f7'>{icon}</span> {volume}%";
            format-muted = "";
            tooltip = false;
            format-icons = {
              headphone = "";
              default = [ "" "" "󰕾" "󰕾" "󰕾" "" "" "" ];
            };
            scroll-step = 1;
          };
          "bluetooth" = {
            format = "<span color='#cba6f7'></span> {status}";
            format-disabled = "";
            format-connected = "<span color='#cba6f7'></span> {num_connections}";
            tooltip-format = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}   {device_address}";
          };
          "network" = {
            interface = "wlp1s0f0";
            format = "{ifname}";
            format-wifi = "<span color='#cba6f7'> </span>{essid}";
            format-ethernet = "{ipaddr}/{cidr} ";
            format-disconnected = "<span color='#cba6f7'>󰖪 </span>No Network";
            tooltip = false;
          };
          "battery" = {
            format = "<span color='#cba6f7'>{icon}</span> {capacity}%";
            format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
            format-charging = "<span color='#cba6f7'></span> {capacity}%";
            tooltip = false;
          };
        };
      };
      style = ''
        * {
          border: none;
          font-family: 'Fira Code', 'Symbols Nerd Font Mono';
          font-size: 12px;
          font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
          min-height: 12px;
        }

        window#waybar {
          background: transparent;
        }

        #custom-arch, #workspaces {
          border-radius: 8px;
          background-color: #11111b;
          color: #7eb9e3;
          margin-top: 15px;
        	margin-right: 15px;
          padding-top: 1px;
          padding-left: 5px;
          padding-right: 5px;
        }

        #custom-arch {
          font-size: 20px;
        	margin-left: 15px;
        }

        #workspaces button {
          background: #11111b;
          color: #cdd6f4;
        }

        #workspaces button.active {
          color: #cba6f7;
        }

        #clock, #backlight, #pulseaudio, #bluetooth, #network, #battery{
          border-radius: 10px;
          background-color: #11111b;
          color: #cdd6f4;
          margin-top: 15px;
          padding-left: 10px;
          padding-right: 10px;
          margin-right: 15px;
        }

        #backlight, #bluetooth {
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          padding-right: 5px;
          margin-right: 0
        }

        #pulseaudio, #network {
          border-top-left-radius: 0;
          border-bottom-left-radius: 0;
          padding-left: 5px;
        }

        #clock {
          margin-right: 0;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: black;
          }
        }

        #battery.warning:not(.charging) {
          background: #f38ba8;
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
      '';
    };
  };
}
