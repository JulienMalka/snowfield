{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.luj.programs.mosh;
in
with lib;
{
  options.luj.programs.mosh = {
    enable = mkEnableOption "Enable mosh program";
  };

  config = mkIf cfg.enable
    {
      programs.mosh.enable = true;
      networking.firewall.allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
    };
}
