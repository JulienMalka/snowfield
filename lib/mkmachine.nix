inputs: lib:

let
  overlay-unstable = arch: _final: _prev:
    {
      unstable = import inputs.unstable { };
    };
in

{ host-config, modules, nixpkgs ? inputs.nixpkgs, system ? "x86_64-linux", home-manager ? inputs.home-manager }:
let pkgs = import nixpkgs { };
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = pkgs.lib.extend (import ./default.nix inputs);
  specialArgs =
    {
      inherit inputs;
    };
  modules = builtins.attrValues modules ++ [
    ../machines/base.nix
    host-config
    (import "${inputs.sops-nix}/modules/sops")
    (import "${inputs.home-manager}/nixos")
    (import "${inputs.nixos-mailserver}")
    (import "${inputs.attic}/nixos/atticd.nix")
    (import "${inputs.lanzaboote}/nix/modules/lanzaboote.nix")
    (import "${inputs.buildbot-nix}/nix/master.nix")
    (import "${inputs.buildbot-nix}/nix/worker.nix")
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
            zotero = pkgs.wrapFirefox (pkgs.callPackage "${inputs.zotero-nix}/pkgs" { }) { };
            attic = import inputs.attic;
            colmena = import inputs.colmena;
            inherit (prev.unstable) bcachefs-tools;
            # My own packages
            keycloak-keywind = prev.pkgs.callPackage ../packages/keycloak-keywind { };
            hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
          })
      ];
    }
  ];
  extraModules =
    let
      colmenaModules = import
        "${inputs.colmena}/src/nix/hive/options.nix";
    in
    [ colmenaModules.deploymentOptions ];
}

