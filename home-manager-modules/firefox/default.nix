{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.firefox;
in
with lib;
{
  options.luj.programs.firefox = {
    enable = mkEnableOption "Enable Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      profiles.default = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          ublock-origin
        ];

      };
    };

  };
}
