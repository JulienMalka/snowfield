{ config, lib, ... }:
let
  cfg = config.luj.programs.dunst;
in
with lib;
{
  options.luj.programs.dunst = {
    enable = mkEnableOption "Enable Dunst";
  };

  config = mkIf cfg.enable {

    services.dunst = {
      enable = true;
      settings = {
        global = {
          corner_radius = 5;
          follow = "mouse";
          frame_color = "#89B4FA";
          frame_width = 0;
          separator_color = "frame";
        };

        urgency_low = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
        };
        urgency_normal = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
        };

        urgency_critical = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
          frame_color = "#FAB387";
        };

      };

    };
  };

}
