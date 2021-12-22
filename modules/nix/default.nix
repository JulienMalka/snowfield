{ pkgs, config, lib, inputs, ... }:
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
        allowedUsers = [ "julien" "hydra" ];
        gc = {
          automatic = true;
          dates = "daily";
        };
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
        ]; 
      };


    };
}
