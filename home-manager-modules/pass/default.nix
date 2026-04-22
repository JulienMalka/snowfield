{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.pass;
in
{
  options.luj.programs.pass = {
    enable = lib.mkEnableOption "Enable pass";
  };

  config = lib.mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vaults.malka.family";
        email = "julien@malka.sh";
        pinentry = pkgs.unstable.pinentry-tty;
        lock_timeout = 600;
      };
    };
  };

}
