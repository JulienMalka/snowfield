{ config, lib, ... }:
let
  cfg = config.luj.secrets;
in
with lib;
{
  options.luj.secrets = {
    enable = mkEnableOption "Create secrets";
  };

  config = mkIf cfg.enable {

    age.secrets.ens-mail-password = {
      file = ../../secrets/ens-mail-password.age;
      owner = "julien";
      path = "/home/julien/.config/ens-mail-passwd";
    };

    age.secrets.git-gpg-private-key = {
      file = ../../secrets/git-gpg-private-key.age;
      owner = "julien";
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
}
