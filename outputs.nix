# The flake's outputs, as built before the move from lon. `inputs` are the
# flake inputs (including `self`).
{ inputs }:
let
  inputs_final = inputs;
  dnsLib = inputs.dns.lib;
  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs_final self.profiles dnsLib);
  mkLibForMachine =
    machine:
    (import "${lib.snowfield.${machine}.nixpkgs_version}/lib").extend (
      import ./lib inputs_final self.profiles dnsLib
    );
  machines_plats = lib.lists.unique (
    lib.mapAttrsToList (_name: value: value.arch) (
      lib.filterAttrs (_n: v: builtins.hasAttr "arch" v) lib.snowfield
    )
  );

  nixpkgs_plats = builtins.listToAttrs (
    builtins.map (plat: {
      name = plat;
      value = import inputs.nixpkgs { system = plat; };
    }) machines_plats
  );
  self = rec {

    inherit lib;

    nixosModules = lib.importConfig ./modules;

    profiles = builtins.listToAttrs (
      map (x: {
        name = lib.strings.removeSuffix ".nix" x;
        value = import (./profiles + "/${x}");
      }) (builtins.attrNames (lib.discovery.nixFiles ./profiles))
    );

    nixosConfigurations = builtins.mapAttrs (
      name: value:
      (lib.mkMachine {
        inherit name self dnsLib;
        host-config = value;
        modules = builtins.attrValues nixosModules ++ lib.snowfield.${name}.profiles;
        nixpkgs = lib.snowfield.${name}.nixpkgs_version;
        system = lib.snowfield.${name}.arch;
        home-manager = lib.snowfield.${name}.hm_version;
      })
    ) (lib.importConfig ./machines);

    colmena = {
      meta = {
        # colmena evaluates flakes hermetically: it needs a default nixpkgs
        # even though every node is pinned, and all of them instantiated,
        # since there is no currentSystem to guess from.
        nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (
          n: _: import lib.snowfield.${n}.nixpkgs_version { system = lib.snowfield.${n}.arch; }
        ) nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (
          n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
        ) nixosConfigurations;
      };
    }
    // builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations;

    all_secrets_nixos = lib.foldl (acc: v: lib.deepMerge acc v) { } (
      lib.attrValues (
        lib.mapAttrs (
          n: v:
          lib.mapAttrs' (
            _: j: lib.nameValuePair (builtins.toString j.file) (j // { targets = [ n ]; })
          ) v.config.age.secrets
        ) nixosConfigurations
      )
    );

    all_secrets_hm = lib.foldl (acc: v: lib.deepMerge acc v) { } (
      lib.attrValues (
        lib.mapAttrs (
          n: v:
          lib.mapAttrs' (
            _: j: lib.nameValuePair (builtins.toString j.file) (j // { targets = [ "${n}_home" ]; })
          ) v.config.home-manager.users.julien.age.secrets
        ) nixosConfigurations
      )
    );

    all_secrets = lib.deepMerge all_secrets_nixos all_secrets_hm;

    packages = lib.genAttrs machines_plats (
      system:
      let
        pkgs = nixpkgs_plats.${system};
        unstable = import inputs.unstable { inherit system; };
        localPackages = import ./lib/local-packages.nix { inherit pkgs unstable inputs; };
      in
      lib.filterAttrs (
        _: package:
        !(lib.hasAttrByPath [ "meta" "platforms" ] package) || builtins.elem system package.meta.platforms
      ) localPackages
    );

    # comin's nix executor appends both .toplevel and .config.services.comin.machineId
    # to systemAttr, so we need an attrset with both at the same level
    cominConfigurations = builtins.mapAttrs (
      _: v: v.config.system.build // { inherit (v) config; }
    ) nixosConfigurations;

    checks = {
      inherit packages tests;
      machines = lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
    };

    # The unit tests only exercise pure library functions, so one platform is
    # enough. Reuse an already-instantiated nixpkgs when the machines provide
    # one, rather than evaluating a second copy.
    tests = import ./tests {
      inherit lib;
      pkgs = nixpkgs_plats.x86_64-linux or (import inputs.nixpkgs { system = "x86_64-linux"; });
    };
  };
in
self
