{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.luj.secrets;
in
with lib;
{
  options.luj.secrets = {
    enable = mkEnableOption "Create secrets";
  };

  config = mkIf cfg.enable
    {
      sops.secrets.ens-mail-passwd = {
        owner = "julien";
        path = "/home/julien/.config/ens-mail-passwd";
      };

      sops.secrets.sendinblue-mail-passwd = {};
      sops.secrets.git-gpg-private-key = {};
      
      };


}
