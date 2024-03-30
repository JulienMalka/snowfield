{ config, lib, ... }:
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

  };
}
