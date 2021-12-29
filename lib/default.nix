inputs: final: prev: 

with builtins; with inputs;

let
  overlay-unstable = final: prev: {
    unstable = unstable.legacyPackages.x86_64-linux;
  };
in
{

  mkMachine = host: host-config: modules: nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ../base.nix
      sops-nix.nixosModules.sops
      host-config
      home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlay
          overlay-unstable
          (final: prev:
            {
              tinystatus = prev.pkgs.callPackage ../packages/tinystatus {};
              mosh = prev.pkgs.callPackage ../packages/mosh {};
            })
        ];
      }
    ];
  };

  importConfig = with builtins; path: (mapAttrs (name: value: import (path + "/${name}/default.nix")) (readDir path));

}

