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
      userEmail = "julien@malka.sh";
      signing = {
        signByDefault = true;
        key = "6FC74C847011FD83";
      };
      extraConfig.init.defaultBranch = "main";
    };

    home.extraActivationPath = [ pkgs.gnupg ];
    home.activation =
      {
        myActivationAction = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          gpg --import /run/secrets/git-gpg-private-key
        '';
      };
  };
}
