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
        sas = {
          hostname = "sas.eleves.ens.fr";
          user = "jmalka";
        };
        "*" = {
          hostname = "%h.luj";
          user = "julien";
          port = 45;
        };
      };
    };
  };
}
