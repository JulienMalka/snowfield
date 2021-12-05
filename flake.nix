{
  description = "A flake for my personnal configurations";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    homepage = {
      url = "github:JulienMalka/homepage";
      flake = false;
    };


  };

  outputs = { self, home-manager, nixpkgs, neovim-nightly-overlay, nur, ... }@inputs:
    let
      importDir = dir: pipe dir [
        builtins.readDir
        (mapAttrsToList (name: type:
          if type == "regular" && hasSuffix ".nix" name && name != "default.nix" then
            [{ name = removeSuffix ".nix" name; value = import (dir + "/${name}"); }]
          else if type == "directory" && pathExists (dir + "/${name}/default.nix") then
            [{ inherit name; value = import (dir + "/${name}"); }]
          else
            [ ]
        ))
        concatLists
        listToAttrs
      ];
      mkMachine = host: host-config: modules: {
        lisa = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
      };
    in
    {
      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = mapAttrs (name: value: (mkMachine name value nixosModules)) (importDir ./machines);




    };



}
