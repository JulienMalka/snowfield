{
  description = "A flake for my personnal configurations";
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "unstable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/17198cf5ae27af5b647c7dac58d935a7d0dbd189";
      inputs.nixpkgs.follows = "unstable";
    };

    homepage = {
      url = "github:JulienMalka/homepage";
      flake = false;
    };

    unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "unstable";
    };

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

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon/";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

  };

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs:
    let
      lib = nixpkgs.lib.extend (import ./lib inputs);
      machines_plats = lib.mapAttrsToList (name: value: value.arch) lib.luj.machines;

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

      deploy.nodes.lambda = {
        hostname = "lambda.julienmalka.me";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          remoteBuild = true;
          fastConnection = true;
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.lambda;
        };
      };

      deploy.nodes.lisa = {
        hostname = "lisa.julienmalka.me";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lisa;
        };
      };

      deploy.nodes.bin-cache = {
        hostname = "bin-cache.julienmalka.me";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lisa;
        };
      };


      deploy.nodes.tower = {
        hostname = "tower.julienmalka.me";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          magicRollback = false;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.tower;
        };
      };

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


      hydraJobs = {
        machines.tower = self.nixosConfigurations.tower.config.system.build.toplevel;
        machines.lisa = self.nixosConfigurations.lisa.config.system.build.toplevel;
        machines.macintosh = self.nixosConfigurations.macintosh.config.system.build.toplevel;
        machines.lambda = self.nixosConfigurations.lambda.config.system.build.toplevel;
        machines.bin-cache = self.nixosConfigurations.bin-cache.config.system.build.toplevel;
        packages.x86_64-linux = packages.x86_64-linux;
        packages.aarch64-linux = packages.aarch64-linux;
      };

    };
}
