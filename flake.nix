{
  description = "A flake for my personnal configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

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

    hardware = {
      url = "github:NixOS/nixos-hardware";
    };
      
  };

  outputs = { self, home-manager, nixpkgs, neovim-nightly-overlay, nur, ... }@inputs:
    let
      utils = import ./utils.nix { inherit nixpkgs home-manager inputs; };
      pkgs = import nixpkgs { };
    in
    with utils;
    {
      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = builtins.mapAttrs (name: value: (mkMachine name value self.nixosModules)) (importConfig ./machines);
       hydraJobs = (nixpkgs.lib.mapAttrs' (name: config:
        nixpkgs.lib.nameValuePair "nixos-${name}"
        config.config.system.build.toplevel) self.nixosConfigurations);

    };
}
