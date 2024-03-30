{ config, lib, ... }:
let
  cfg = config.luj.programs.alacritty;
in
with lib;
{
  options.luj.programs.alacritty = {
    enable = mkEnableOption "Enable alacritty program";
  };

  config = mkIf cfg.enable
    {
      programs.alacritty.enable = true;
      xdg.configFile."alacritty/alacritty.yml".source = lib.mkForce ./config;
    };
}
    
