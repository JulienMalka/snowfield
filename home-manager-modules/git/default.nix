{
  config,
  pkgs,
  lib,
  ...
}:
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
      settings = {
        user.name = "Julien Malka";
        user.email = "julien@malka.sh";
        init.defaultBranch = "main";
        diff.colorMoved = "zebra";
        pull.rebase = true;
        fetch.prune = true;
        rebase.autoStash = true;
        push.autoSetupRemote = true;

      };
      signing = {
        signByDefault = true;
        key = "6FC74C847011FD83";
      };
      maintenance = {
        enable = true;
        repositories = [
          "/home/julien/dev/nixpkgs"
        ];
      };
      ignores = [ ".direnv" ];
    };

    programs.delta.enable = true;

    home.extraActivationPath = [ pkgs.gnupg ];
    home.activation = {
      myActivationAction = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        gpg --import /run/agenix/git-gpg-private-key
      '';
    };
  };
}
