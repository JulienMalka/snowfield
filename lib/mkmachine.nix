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
  preservationLib = import "${inputs.preservation}/lib.nix" { inherit (pkgs) lib; };
  ourLib = import ./default.nix inputs self.profiles dnsLib;
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = (pkgs.lib.extend ourLib) // preservationLib;
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

    (import inputs.lanzaboote { }).nixosModules.lanzaboote
    (import inputs.lila).nixosModules.hash-collection
    (import "${inputs.stateless-uptime-kuma}/nixos/module.nix")
    (import "${inputs.proxmox}/modules/declarative-vms")
    (import "${inputs.preservation}/module.nix")
    (import "${inputs.luj-website}/nix/module.nix")
    (import "${inputs.niks3}/nix/nixosModules/niks3.nix")
    (import "${inputs.comin}/nix/module.nix" {
      self = {
        packages.${system}.comin = pkgs.callPackage "${inputs.comin}/nix/package.nix" { };
      };
    })
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      nixpkgs.system = system;
      networking.hostName = name;
      nixpkgs.overlays = lib.mkAfter [
        (overlay-unstable system)

        # Local packages in ../packages/ are auto-imported by directory name.
        # Packages listed in `unstablePackages` are called via the unstable
        # nixpkgs scope; the rest use the machine's default channel.
        (
          _final: prev:
          let
            unstablePackages = [ "openclaw" ];
            callLocal =
              name:
              let
                scope = if builtins.elem name unstablePackages then prev.pkgs.unstable else prev.pkgs;
              in
              scope.callPackage (../packages + "/${name}") { };
            localPackages = lib.genAttrs (builtins.attrNames (
              lib.filterAttrs (_: v: v == "directory") (builtins.readDir ../packages)
            )) callLocal;
          in
          localPackages
          // {
            waybar = prev.waybar.overrideAttrs (oldAttrs: {
              mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
            });

            lila-build-hook = (import inputs.lila).packages.${system}.utils;
            artiflakery = (import inputs.artiflakery).defaultPackage.${system};

            inherit (prev.pkgs.unstable) river;

            claude-code = prev.pkgs.callPackage "${inputs.llm-agents}/packages/claude-code/package.nix" {
              wrapBuddy = prev.pkgs.callPackage "${inputs.llm-agents}/packages/wrapBuddy/package.nix" { };
            };
            luj-website = prev.pkgs.callPackage "${inputs.luj-website}/nix/package.nix" {
              src = inputs.luj-website;
              inherit (prev.unstable) cargo-leptos;
            };
          }
        )

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
