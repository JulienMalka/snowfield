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
        package = pkgs.unstable.nix;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
          "nixos=${inputs.nixpkgs}"
        ];
        settings =
          {
            auto-optimise-store = true;
            substituters = [
              "https://cache.nixos.org"
              "https://bin.julienmalka.me"
            ];
            trusted-public-keys = [
              "bin.julienmalka.me:RfXA+kPZt3SsMHGib5fY5mxJQLijfXzPbHjHD52ijyI="
            ];
          };

      };

    };
}
