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
      nixpkgs.config.allowUnfree = true;
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
        binaryCaches = [
          "https://bin.julienmalka.me"
          "https://cache.nixos.org/"
        ];
        binaryCachePublicKeys = [
          "bin.julienmalka.me:y0uADfX8ZQ6Pthofm8Pj7v+hED3m2cY0d+Sg6/Jm+s8="
        ];

      };


    };
}
