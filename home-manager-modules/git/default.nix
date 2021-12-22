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
        key = "3C68E13964FEA07F";
      };
    };

    home.extraActivationPath = [ pkgs.gnupg ];
    home.activation = 
        {
          myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
          gpg --import /run/secrets/git-gpg-private-key
          '';
        };
  };
}
