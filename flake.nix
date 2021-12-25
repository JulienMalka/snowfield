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
      inputs.nixpkgs.follows = "unstable";
    };
    homepage = {
      url = "github:JulienMalka/homepage";
      flake = false;
    };

    unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, home-manager, nixpkgs, unstable, sops-nix, neovim-nightly-overlay, nur, ... }@inputs:
    let
      utils = import ./utils.nix { inherit nixpkgs sops-nix home-manager inputs; nixpkgs-unstable = unstable; };
      pkgs = import nixpkgs { system = "x86_64-linux"; };
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
      packages."x86_64-linux".tinystatus = import ./packages/tinystatus { inherit pkgs; };
    };
}
