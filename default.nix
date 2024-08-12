let
  inputs = import ./deps;
  patch = import inputs.nix-patches { patchFile = ./patches; };
  inputs_final = inputs // {
    nixpkgs_patched = patch.mkNixpkgsSrc {
      src = inputs.unstable;
      version = "nixos-unstable";
    };
  };
  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs_final);
  mkLibForMachine =
    machine:
    (import "${lib.snowfield.${machine}.nixpkgs_version}/lib").extend (import ./lib inputs_final);
  machines_plats = lib.lists.unique (
    lib.mapAttrsToList (_name: value: value.arch) (
      lib.filterAttrs (_n: v: builtins.hasAttr "arch" v) lib.snowfield
    )
  );
  mkMachine = import ./lib/mkmachine.nix inputs_final lib;

  nixpkgs_plats = builtins.listToAttrs (
    builtins.map (plat: {
      name = plat;
      value = import inputs.nixpkgs { system = plat; };
    }) machines_plats
  );
  self = rec {

    nixosModules = builtins.listToAttrs (
      map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./modules))
    );

    nixosConfigurations = builtins.mapAttrs (
      name: value:
      (mkMachine {
        inherit name self;
        host-config = value;
        modules = nixosModules;
        nixpkgs = lib.snowfield.${name}.nixpkgs_version;
        system = lib.snowfield.${name}.arch;
        home-manager = lib.snowfield.${name}.hm_version;
      })
    ) (lib.importConfig ./machines);

    colmena = {
      meta = {
        nodeNixpkgs = builtins.mapAttrs (
          n: _: import lib.luj.machines.${n}.nixpkgs_version
        ) nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (
          n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
        ) nixosConfigurations;
      };
    } // builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations;

    packages = builtins.listToAttrs (
      builtins.map (plat: {
        name = plat;
        value =
          lib.filterAttrs
            (
              _name: value:
              (
                !lib.hasAttrByPath [
                  "meta"
                  "platforms"
                ] value
              )
              || builtins.elem plat value.meta.platforms
            )
            (
              builtins.listToAttrs (
                builtins.map (e: {
                  name = e;
                  value = nixpkgs_plats.${plat}.callPackage (./packages + "/${e}") { };
                }) (builtins.attrNames (builtins.readDir ./packages))
              )
            );
      }) machines_plats
    );

    inherit (lib.luj) machines;

    checks = {
      inherit packages;
      machines = lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
    };
  };
in
self
