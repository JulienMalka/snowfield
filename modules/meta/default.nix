{
  pkgs,
  lib,
  profiles,
  ...
}:
{
  options.machine.meta = lib.mkOption {
    description = "Machine metadata";
    type =
      with lib;
      types.submodule (
        { name, ... }:
        {
          freeformType =
            with types;
            oneOf [
              str
              attrs
            ];
          options = {
            hostname = mkOption {
              description = "The machine's hostname";
              type = types.str;
              default = name;
              readOnly = true;
            };
            sshPort = mkOption {
              description = "The port for the ssh server of the machine";
              type = types.int;
              default = 45;
            };
            sshUser = mkOption {
              description = "The user for ssh connection to the machine";
              default = "julien";
            };
            tld = mkOption {
              description = "tld for local addressing of the machine";
              default = "luj";
            };
            profiles = mkOption {
              description = "profiles applied to the machine";
              default = with profiles; [ base ];
            };

            probes = {
              monitors = lib.mkOption {
                type = types.attrsOf (pkgs.formats.json { }).type;
                default = { };
              };
              tags = lib.mkOption {
                type = types.attrsOf (pkgs.formats.json { }).type;
                default = { };
              };
              notifications = lib.mkOption {
                type = types.attrsOf (pkgs.formats.json { }).type;
                default = { };
              };
              status_pages = lib.mkOption {
                type = types.attrsOf (pkgs.formats.json { }).type;
                default = { };
              };
              settings = lib.mkOption {
                type = types.attrsOf (pkgs.formats.json { }).type;
                default = { };
              };
            };

            defaultInterface = mkOption {
              description = "default interface of the machine";
              default = "ens18";
            };

          };
        }
      );
    default = { };
  };

  config = {
    machine.meta.profiles = [
      profiles.base
      profiles.ssh-server
    ];
  };

}
