let
  inputs = import ./lon.nix;
  dnsLib = (import inputs.dns).lib;
  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs self.profiles dnsLib);
  mkLibForMachine =
    machine:
    (import "${lib.snowfield.${machine}.nixpkgs_version}/lib").extend (
      import ./lib inputs self.profiles dnsLib
    );
  machines_plats = lib.lists.unique (
    lib.mapAttrsToList (_: v: v.arch) (lib.filterAttrs (_: v: v ? arch) lib.snowfield)
  );

  nixpkgs_plats = lib.genAttrs machines_plats (system: import inputs.nixpkgs { inherit system; });

  self = rec {

    inherit lib;

    nixosModules = lib.importDir ./modules;

    profiles = lib.importNixFiles ./profiles;

    nixosConfigurations = lib.mapAttrs (
      name: value:
      lib.mkMachine {
        inherit name self dnsLib;
        host-config = value;
        modules = lib.attrValues nixosModules ++ lib.snowfield.${name}.profiles;
        nixpkgs = lib.snowfield.${name}.nixpkgs_version;
        system = lib.snowfield.${name}.arch;
        home-manager = lib.snowfield.${name}.hm_version;
      }
    ) (lib.importDir ./machines);

    colmena = {
      meta = {
        nodeNixpkgs = lib.mapAttrs (n: _: import lib.snowfield.${n}.nixpkgs_version) nixosConfigurations;
        nodeSpecialArgs = lib.mapAttrs (
          n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
        ) nixosConfigurations;
      };
    }
    // lib.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations;

    all_secrets = lib.collectSecrets nixosConfigurations;

    packages = lib.genAttrs machines_plats (
      plat:
      lib.filterAttrs (
        _: v: !(lib.hasAttrByPath [ "meta" "platforms" ] v) || builtins.elem plat v.meta.platforms
      ) (lib.mapAttrs (_: drv: nixpkgs_plats.${plat}.callPackage drv { }) (lib.importDir ./packages))
    );

    # comin's nix executor appends both .toplevel and .config.services.comin.machineId
    # to systemAttr, so we need an attrset with both at the same level
    cominConfigurations = lib.mapAttrs (
      _: v: v.config.system.build // { inherit (v) config; }
    ) nixosConfigurations;

    checks = {
      inherit packages;
      machines = lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
    };
  };
in
self
