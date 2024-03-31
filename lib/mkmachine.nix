inputs: lib:

let
  overlay-unstable = arch: _final: _prev:
    let
      nixpkgs-patched-src = (import inputs.nixpkgs { system = arch; }).applyPatches {
        name = "nixpkgs-patches";
        src = inputs.nixpkgs;
        patches = [ ];
      };
    in
    {
      unstable = inputs.unstable.legacyPackages."${arch}";
      nixpkgs-patched = import nixpkgs-patched-src { system = arch; };
      stable = inputs.nixpkgs.legacyPackages."${arch}";
    };
in

{ host-config, modules, nixpkgs ? inputs.nixpkgs, system ? "x86_64-linux", home-manager ? inputs.home-manager }:
nixpkgs.lib.nixosSystem {
  inherit system;
  lib = nixpkgs.lib.extend (import ./default.nix inputs);
  specialArgs =
    {
      inherit inputs;
    };
  modules = builtins.attrValues modules ++ [
    ../machines/base.nix
    host-config
    inputs.sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    inputs.simple-nixos-mailserver.nixosModule
    inputs.attic.nixosModules.atticd
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    {
      home-manager.useGlobalPkgs = true;
      nixpkgs.overlays = [
        (overlay-unstable system)
        (_final: prev:
          {
            waybar = prev.waybar.overrideAttrs (oldAttrs: {
              mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
            });
            # Packages comming from other repositories
            attic = inputs.attic.packages.${system}.default;
            inherit (inputs.colmena.packages.${system}) colmena;
            inherit (prev.unstable) bcachefs-tools;
            zotero = inputs.zotero-nix.packages.${system}.default;
            # My own packages
            keycloak-keywind = prev.pkgs.callPackage ../packages/keycloak-keywind { };
            hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
          })
      ];
    }
  ];
  extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
}

