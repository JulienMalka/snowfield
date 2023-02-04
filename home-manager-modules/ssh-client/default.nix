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
          hostname = "lisa.julienmalka.me";
          user = "julien";
          port = 45;
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
        lambda = {
          hostname = "lambda.julienmalka.me";
          user = "root";
          port = 45;
        };
        tower = {
          hostname = "tower.julienmalka.me";
          user = "julien";
          port = 45;
        };
        saumon = {
          hostname = "saumon.julienmalka.me";
          user = "julien";
        };
        stockly = {
          hostname = "charybdis.stockly.ai";
          user = "julien_malka";
          port = 23;
        };
      };
    };
  };
}
