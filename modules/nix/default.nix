{
  config,
  lib,
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
        "nixpkgs=${config.machine.meta.nixpkgs_version}"
        "nixos=${config.machine.meta.nixpkgs_version}"
      ];
      settings = {
        builders-use-substitutes = true;
        auto-optimise-store = true;
        # NixOS already adds https://cache.nixos.org/; listing it again
        # without the trailing slash made Nix treat it as a second cache and
        # repeat every lookup that misses there.
        substituters = [ "https://cache.luj.fr" ];
        trusted-public-keys = [
          "cache.luj.fr-1:C4ZpEGda4niPPcPtSMTzfiz1OLl8a+HzSdq1hUhAh6w="
        ];
      };
    };
  };
}
