{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.luj.nix;
in
with lib;
{
  options.luj.nix = {
    enable = mkEnableOption "Enable nix experimental";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.unstable.lix;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
        "nixos=${inputs.nixpkgs}"
      ];
      settings = {
        builders-use-substitutes = true;
        auto-optimise-store = true;
        substituters = [
          "https://cache.nixos.org"
          "https://cache.saumon.network/attic-exec?priority=100"
        ];
        trusted-public-keys = [ "attic-exec:W1PQ0txRf4qpCIlNLscD/Xw1GwGoBij73JSum/I8Xt4=" ];
      };
    };
  };
}
