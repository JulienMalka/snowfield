inputs: lib:

let
  overlay-unstable = arch: _final: _prev: {
    stable = import inputs.nixpkgs { system = arch; };
    unstable = import inputs.unstable { system = arch; };
  };
in

{
  name,
  host-config,
  modules,
  nixpkgs ? inputs.nixpkgs,
  system ? "x86_64-linux",
  home-manager ? inputs.home-manager,
  self,
  dnsLib,
}:
let
  pkgs = import nixpkgs { inherit system; };
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = pkgs.lib.extend (import ./default.nix inputs self.profiles dnsLib);
  specialArgs = {
    inherit inputs dnsLib;
    inherit (self) nixosConfigurations profiles;
  };
  modules = modules ++ [
    host-config
    (import "${home-manager}/nixos")
    (import "${inputs.disko}/module.nix")
    (import "${inputs.buildbot-nix}/nix/master.nix")
    (import "${inputs.buildbot-nix}/nix/worker.nix")
    (import "${inputs.agenix}/modules/age.nix")
    (import "${inputs.artiflakery}/module.nix")
    (import "${inputs.impermanence}/nixos.nix")
    (import inputs.lanzaboote).nixosModules.lanzaboote
    (import inputs.lila).nixosModules.hash-collection
    (import "${inputs.stateless-uptime-kuma}/nixos/module.nix")
    (import "${inputs.proxmox}/modules/declarative-vms")
    {
      home-manager.useGlobalPkgs = true;
      nixpkgs.system = system;
      networking.hostName = name;
      nixpkgs.overlays = lib.mkAfter [
        (overlay-unstable system)
        (import "${inputs.emacs-overlay}/overlays/emacs.nix")
        (_final: prev: {
          waybar = prev.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
          });
          # Packages comming from other repositories
          lila-build-hook = (import inputs.lila).packages.${system}.utils;
          artiflakery = (import inputs.artiflakery).defaultPackage.${system};
          # My own packages
          keycloak-keywind = prev.pkgs.callPackage ../packages/keycloak-keywind { };
          hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
          codeberg-pages-custom = prev.pkgs.callPackage ../packages/codeberg-pages-custom { };
          lcli = prev.pkgs.callPackage ../packages/lcli { };
          uptime-kuma-beta = prev.pkgs.callPackage ../packages/uptime-kuma-beta { };
        })

        (
          _final: prev:
          let
            generated = import "${inputs.nix-index-database}/generated.nix";
            nix-index-database =
              (prev.fetchurl {
                url = generated.url + prev.stdenv.system;
                hash = generated.hashes.${prev.stdenv.system};
              }).overrideAttrs
                {
                  __structuredAttrs = true;
                  unsafeDiscardReferences.out = true;
                };
          in
          {
            inherit nix-index-database;
            nix-index-with-db = prev.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
              inherit nix-index-database;
            };
            comma-with-db = prev.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
              inherit nix-index-database;
            };
          }
        )

      ];
    }
  ];
  extraModules =
    let
      colmenaModules = import "${inputs.colmena}/src/nix/hive/options.nix";
    in
    [ colmenaModules.deploymentOptions ];
}
