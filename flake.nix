{
  description = "A flake for my personnal configurations";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "unstable";
    };

    homepage = {
      url = "github:JulienMalka/homepage";
      flake = false;
    };

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    colmena.url = "github:zhaofengli/colmena";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-22_11.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    linkal = {
      url = "github:JulienMalka/Linkal/main";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon/";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprpaper.url = "github:hyprwm/hyprpaper";

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rfc-92.url = "github:obsidiansystems/nix/dynamic-drvs";

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib.extend (import ./lib inputs);
      machines_plats = lib.mapAttrsToList (name: value: value.arch) (lib.filterAttrs (n: v: builtins.hasAttr "arch" v) lib.luj.machines);

      nixpkgs_plats = builtins.listToAttrs (builtins.map
        (plat: {
          name = plat;
          value = import nixpkgs { system = plat; };
        })
        machines_plats);
    in
    rec {

      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = builtins.mapAttrs
        (name: value: (lib.mkMachine {
          host = name;
          host-config = value;
          modules = self.nixosModules;
          nixpkgs = lib.luj.machines.${name}.nixpkgs_version;
          system = lib.luj.machines.${name}.arch;
          home-manager = lib.luj.machines.${name}.hm_version;
        }))
        (lib.importConfig ./machines);


      colmena = {
        meta = {
          nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
          nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) nixosConfigurations;
          nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) nixosConfigurations;
          specialArgs.lib = lib;
        };
      } // builtins.mapAttrs (name: value: { imports = value._module.args.modules; }) nixosConfigurations;


      packages = builtins.listToAttrs
        (builtins.map
          (plat: {
            name = plat;
            value =
              (lib.filterAttrs (name: value: (!lib.hasAttrByPath [ "meta" "platforms" ] value) || builtins.elem plat value.meta.platforms)
                (builtins.listToAttrs (builtins.map
                  (e: {
                    name = e;
                    value = nixpkgs_plats.${plat}.callPackage (./packages + "/${e}") { };
                  })
                  (builtins.attrNames (builtins.readDir ./packages)))));
          })
          machines_plats);

      machines = lib.luj.machines;

      hydraJobs = {
        machines.tower = self.nixosConfigurations.tower.config.system.build.toplevel;
        machines.lisa = self.nixosConfigurations.lisa.config.system.build.toplevel;
        machines.macintosh = self.nixosConfigurations.macintosh.config.system.build.toplevel;
        machines.lambda = self.nixosConfigurations.lambda.config.system.build.toplevel;
        packages.x86_64-linux = packages.x86_64-linux;
        packages.aarch64-linux = packages.aarch64-linux;
      };

    };
}
