inputs: lib:

let
  overlay-unstable = arch: _final: _prev: { unstable = import inputs.unstable { system = arch; }; };
in

{
  name,
  host-config,
  modules,
  nixpkgs ? inputs.nixpkgs,
  system ? "x86_64-linux",
  home-manager ? inputs.home-manager,
}:
let
  pkgs = import nixpkgs { inherit system; };
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = pkgs.lib.extend (import ./default.nix inputs);
  specialArgs = {
    inherit inputs;
  };
  modules = builtins.attrValues modules ++ [
    ../machines/base.nix
    host-config
    (import "${home-manager}/nixos")
    (import "${inputs.nixos-mailserver}")
    (import "${inputs.attic}/nixos/atticd.nix")
    (import "${inputs.disko}/module.nix")
    (import "${inputs.buildbot-nix}/nix/master.nix")
    (import "${inputs.buildbot-nix}/nix/worker.nix")
    (import "${inputs.agenix}/modules/age.nix")
    (import "${inputs.impermanence}/nixos.nix")
    (import inputs.lanzaboote).nixosModules.lanzaboote
    (import inputs.lila).nixosModules.hash-collection
    (import "${inputs.lix-module}/module.nix" { inherit (inputs) lix; })
    {
      home-manager.useGlobalPkgs = true;
      nixpkgs.system = system;
      networking.hostName = name;
      nixpkgs.overlays = lib.mkAfter [
        # TODO: Remove when https://git.lix.systems/lix-project/lix/issues/310 is fixed
        (_: prev: {
          nix = prev.nix.overrideAttrs (_: {
            doCheck = false;
          });
        })
        (overlay-unstable system)
        (_final: prev: {
          waybar = prev.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
          });
          # Packages comming from other repositories
          zotero = pkgs.wrapFirefox (pkgs.callPackage "${inputs.zotero-nix}/pkgs" { }) { };
          attic = pkgs.callPackage "${inputs.attic}/package.nix" { };
          jackett = pkgs.callPackage ../packages/jackett { };
          lila-build-hook = (import inputs.lila).packages.${system}.utils;
          # My own packages
          keycloak-keywind = prev.pkgs.callPackage ../packages/keycloak-keywind { };
          hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
        })
      ];
    }
  ];
  extraModules =
    let
      colmenaModules = import "${inputs.colmena}/src/nix/hive/options.nix";
    in
    [ colmenaModules.deploymentOptions ];
}
