{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.git;
in
with lib;
{
  options.luj.programs.git = {
    enable = mkEnableOption "Enable git program";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Julien Malka";
      userEmail = "julien.malka@me.com";
      signing = {
        signByDefault = true;
        key = "D00126C95ACC7547BDE2DC523C68E13964FEA07F";
      };
    };
  };
}
