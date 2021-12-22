{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.ssh-client;
in
with lib;
{
  options.luj.programs.ssh-client = {
    enable = mkEnableOption "Enable ssh client";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        newton = {
          hostname = "newton.julienmalka.me";
          user = "julien";
          port = 45;
        };
        lisa = {
          hostname = "2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb";
          user = "julien";
#          port = 45;
        };
        newton-init = {
          hostname = "newton.julienmalka.me";
          user = "root";
          port = 2222;
        };
        sas = {
          hostname = "sas.eleves.ens.fr";
          user = "jmalka";
        };
      };
    };
  };
}
