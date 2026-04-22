{ config, lib, ... }:
let
  cfg = config.luj.programs.emacs;
in
{
  options.luj.programs.emacs = {
    enable = lib.mkEnableOption "Enable Emacs";
  };

  config = lib.mkIf cfg.enable {

    services.emacs.enable = true;

  };
}
