{ pkgs, config, lib, ... }:
let
  cfg = config.luj.nix;
in
with lib;
{
  options.luj.nix = {
    enable = mkEnableOption "Enable nix experimental";
  };

  config = mkIf cfg.enable
    {
      nix = {
        autoOptimiseStore = true;
        allowedUsers = [ "julien" ];
        gc = {
          automatic = true;
          dates = "daily";
        };
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };


    };
}
