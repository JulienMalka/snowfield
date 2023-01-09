{
  description = "A flake for my personnal configurations";
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "flake-utils";
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

  };

  outputs = { self, home-manager, nixpkgs, unstable, deploy-rs, sops-nix, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgsrpi = import nixpkgs { system = "aarch64-linux"; };
      lib = nixpkgs.lib.extend (import ./lib inputs);
    in
    with lib;
    {
      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = builtins.mapAttrs (name: value: (mkMachine { host = name; host-config = value; modules = self.nixosModules; system = luj.machines.${name}.arch; })) (importConfig ./machines);

      deploy.nodes.newton = {
        hostname = "newton.julienmalka.me";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-p" "45" ];
          fastConnection = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.newton;
        };
      };

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



      packages."x86_64-linux" = {
        tinystatus = import ./packages/tinystatus { inherit pkgs; };
        flaresolverr = pkgs.callPackage ./packages/flaresolverr { };
        htpdate = pkgs.callPackage ./packages/htpdate { };
        authelia = pkgs.callPackage ./packages/authelia { };
      };

      packages."aarch64-linux" = {
        tinystatus = import ./packages/tinystatus { pkgs = pkgsrpi; };
        flaresolverr = pkgsrpi.callPackage ./packages/flaresolverr { };
        htpdate = pkgsrpi.callPackage ./packages/htpdate { };
      };

    };
}
