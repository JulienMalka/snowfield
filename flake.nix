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

    unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-utils.url = "github:numtide/flake-utils";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "flake-utils";
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
        hostname = "lambda.luj";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          remoteBuild = true;
          fastConnection = true;
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.lambda;
        };
      };

      deploy.nodes.lisa = {
        hostname = "lisa.luj";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lisa;
          magicRollback = false;
        };
      };

      deploy.nodes.bin-cache = {
        hostname = "100.100.45.22";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bin-cache;
        };
      };

      deploy.nodes.core-security = {
        hostname = "core-security.luj";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.core-security;
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

      lol = import ./lol.nix nixpkgs_plats.x86_64-linux nixosConfigurations.lisa.config.system.build.toplevel.drvPath;

      machines =
        let tld = "luj";
        in {
          lisa = {
            inherit tld;
            ipv4 = { public = "212.129.40.11"; vpn = "100.100.45.12"; };
            ipv6 = { public = "2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb"; vpn = "fd7a:115c:a1e0::c"; };
          };
          lambda = {
            inherit tld;
            ipv4 = { public = "141.145.197.219"; vpn = "100.100.45.13"; };
            ipv6 = { public = "2603:c027:c001:89aa:aad9:34b3:f3c9:924f"; vpn = "fd7a:115c:a1e0::d"; };
          };
          tower = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.0.103"; vpn = "100.100.45.9"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:8ec7:b5d2:f663:a67a"; vpn = "fd7a:115c:a1e0::9"; };
          };
          core-security = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.0.175"; vpn = "100.100.45.14"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:40f0:8cff:fe31:3e94"; vpn = "fd7a:115c:a1e0::e"; };
          };
          nuage = {
            inherit tld;
            subdomains = [ "nuage.malka.family" ];
            ipv4 = { public = "78.194.168.230"; local = "192.168.0.101"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:4ab8:c3d0:a0fe:525f"; };
          };
          pve1 = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.1.1"; vpn = "100.100.45.3"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:d250:99ff:fefa:b62"; vpn = "fd7a:115c:a1e0::3"; };
          };
          pve2 = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.1.2"; vpn = "100.100.45.15"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:aaa1:59ff:fec7:1d6"; vpn = "fd7a:115c:a1e0::f"; };
          };
          pve3 = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.1.3"; vpn = "100.100.45.16"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:aaa1:59ff:fec1:aa10"; vpn = "fd7a:115c:a1e0::10"; };
          };
          pve4 = {
            inherit tld;
            ipv4 = { public = "78.194.168.230"; local = "192.168.1.4"; vpn = "100.100.45.17"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:d250:99ff:fefa:b76"; vpn = "fd7a:115c:a1e0::11"; };
          };
          saves-paris = {
            inherit tld;
            subdomains = [ "saves-paris.luj" ];
            ipv4 = { public = "78.194.168.230"; local = "192.168.4.5"; vpn = "100.100.45.4"; };
            ipv6 = { public = "2a01:e34:ec2a:8e60:3af3:abff:fe6a:1f54"; vpn = "fd7a:115c:a1e0::4"; };
          };

          saves-lyon = {
            inherit tld;
            subdomains = [ "saves-lyon.luj" ];
            ipv4 = { vpn = "100.100.45.20"; };
            ipv6 = { vpn = "fd7a:115c:a1e0::14"; };
          };

        };


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
