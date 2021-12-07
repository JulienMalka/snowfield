{ nixpkgs, home-manager, inputs }:
with builtins;

let mapAttrNames = f: set:
  listToAttrs (map (attr: { name = f attr; value = set.${attr}; }) (attrNames set));
in
{

  mkMachine = host: host-config: modules: nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ./configuration.nix
      host-config
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.julien = import ./config/home/home-lisa.nix;
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlay
        ];
      }
    ];
  };


  importConfig = path: (mapAttrNames (name: nixpkgs.lib.removeSuffix ".nix" name)) ((builtins.mapAttrs (name: value: import (path + "/${name}")) (builtins.readDir path)));


}
