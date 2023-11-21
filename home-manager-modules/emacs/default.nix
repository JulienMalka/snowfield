{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.emacs;
in
with lib;
{
  options.luj.programs.emacs = {
    enable = mkEnableOption "Enable Emacs";
  };

  config = mkIf cfg.enable {

    services.emacs.enable = true;
    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ./doom.d;
      emacsPackage = pkgs.emacs29-pgtk;
    };
  };
}
