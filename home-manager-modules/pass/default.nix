{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.pass;
in
with lib;
{
  options.luj.programs.pass = {
    enable = mkEnableOption "Enable pass";
  };

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vaults.malka.family";
        email = "julien@malka.sh";
        pinentry = pkgs.pinentry-gnome3;
        lock_timeout = 600;
      };
    };
  };

}
