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

    age.secrets.git-gpg-private-key = {
      file = ../../private/secrets/git-gpg-private-key.age;
      owner = "julien";
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
}
