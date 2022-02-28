{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.luj.nix;
in
with lib;
{
  options.luj.nix = {
    enable = mkEnableOption "Enable nix experimental";
  };

  options.nix.gcRoots = mkOption {
    description = "A list of garbage collector roots.";
    type = with types; listOf path;
    default = [];
  };

  config = mkIf cfg.enable
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        autoOptimiseStore = true;
        gc = {
          automatic = true;
          dates = "weekly";
        };
        package = pkgs.unstable.nix;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
          "nixos=${inputs.nixpkgs}"
        ];
        binaryCaches = [
          "https://cache.nixos.org"
          "https://bin.julienmalka.me"
        ];
        binaryCachePublicKeys = [
          "bin.julienmalka.me:y0uADfX8ZQ6Pthofm8Pj7v+hED3m2cY0d+Sg6/Jm+s8="
        ];

        gcRoots = [ inputs.neovim-nightly-overlay inputs.nixpkgs inputs.unstable inputs.home-manager ];
      };
    environment.etc.gc-roots.text = concatMapStrings (x: x + "\n") config.nix.gcRoots;

    };
}
