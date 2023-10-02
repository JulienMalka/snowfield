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
      settings = {
        wayland_titlebar_color = "background";
        background_opacity = "0.96";
        shell_integration = "no-cursor";
      };
      font = {
        name = "FiraCode Nerd Font Mono Reg";
        package = with pkgs; (nerdfonts.override { fonts = [ "FiraCode" ]; });
      };
      theme = "Catppuccin-Mocha";

    };
  };
}
