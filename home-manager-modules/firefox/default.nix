{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.firefox;
in
{
  options.luj.programs.firefox = {
    enable = lib.mkEnableOption "Enable Firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
    };

  };
}
