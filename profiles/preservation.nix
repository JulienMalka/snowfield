{ config, lib, ... }:

let
  cfg = config.luj.preservation;
in
{
  options.luj.preservation = {
    enable = lib.mkEnableOption "declarative /persistent with standard paths";
    earlyBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether `/var/lib` and `/etc/machine-id` must be available inside
        the initrd. Turn this on for servers that start services whose
        state lives under `/var/lib` before stage 2 (comin, agenix secret
        activation, etc.). Workstations leave it off.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/persistent".neededForBoot = true;
    preservation.enable = true;
    preservation.preserveAt."/persistent" = {
      directories = [
        {
          directory = "/var/lib";
          inInitrd = cfg.earlyBoot;
        }
        "/var/log"
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = cfg.earlyBoot;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          mode = "0600";
        }
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };
}
