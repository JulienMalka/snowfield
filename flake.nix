{
  description = "A flake for my personnal configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
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

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, home-manager, nixpkgs, unstable, sops-nix, neovim-nightly-overlay, nur, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgsrpi = import nixpkgs { system = "aarch64-linux"; };
      lib = nixpkgs.lib.extend (import ./lib inputs);
    in
    with lib;
    {
      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = builtins.mapAttrs (name: value: (mkMachine { host = name; host-config = value; modules = self.nixosModules; system = luj.machines.${name}.arch; })) (importConfig ./machines);
      packages."x86_64-linux" = {
        tinystatus = import ./packages/tinystatus { inherit pkgs; };
        mosh = pkgs.callPackage ./packages/mosh { };
        flaresolverr = pkgs.callPackage ./packages/flaresolverr { };
        htpdate = pkgs.callPackage ./packages/htpdate { };
        authelia = pkgs.callPackage ./packages/authelia { };
      };
      packages."aarch64-linux" = {
        tinystatus = import ./packages/tinystatus { pkgs = pkgsrpi; };
        mosh = pkgsrpi.callPackage ./packages/mosh { };
        flaresolverr = pkgsrpi.callPackage ./packages/flaresolverr { };
        htpdate = pkgsrpi.callPackage ./packages/htpdate { };
      };
    };
}
