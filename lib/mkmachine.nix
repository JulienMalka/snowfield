inputs: lib:

let
  overlay-unstable = arch: final: prev:
    let
      nixpkgs-patched-src = (import inputs.nixpkgs { system = arch; }).applyPatches {
        name = "nixpkgs-patches";
        src = inputs.nixpkgs;
        patches = [ ];
      };
    in
    {
      unstable = inputs.unstable.legacyPackages."${arch}";
      nixpkgs-patched = import nixpkgs-patched-src { system = arch; };
      stable = inputs.nixpkgs.legacyPackages."${arch}";
    };
in

{ host, host-config, modules, nixpkgs ? inputs.nixpkgs, system ? "x86_64-linux", home-manager ? inputs.home-manager }:
nixpkgs.lib.nixosSystem {
  inherit system;
  lib = (nixpkgs.lib.extend (import ./default.nix inputs));
  specialArgs =
    {
      inherit inputs;
    };
  modules = builtins.attrValues modules ++ [
    ../machines/base.nix
    inputs.sops-nix.nixosModules.sops
    host-config
    home-manager.nixosModules.home-manager
    inputs.simple-nixos-mailserver.nixosModule
    inputs.attic.nixosModules.atticd
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker

    {
      home-manager.useGlobalPkgs = true;
      nixpkgs.overlays = [
        (overlay-unstable system)
        (final: prev:
          {
            waybar = prev.waybar.overrideAttrs (oldAttrs: {
              mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
            });
            tinystatus = prev.pkgs.callPackage ../packages/tinystatus { };
            jackett = prev.unstable.jackett;
            radarr = prev.unstable.radarr;
            htpdate = prev.pkgs.callPackage ../packages/htpdate { };
            authelia = prev.pkgs.callPackage ../packages/authelia { };
            paperless-ng = prev.pkgs.callPackage ../packages/paperless-ng { };
            tailscale = prev.unstable.tailscale;
            nodePackages = prev.unstable.nodePackages;
            hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
            linkal = inputs.linkal.defaultPackage."${system}";
            mosh = prev.unstable.mosh;
            hyprpaper = inputs.hyprpaper.packages.${system}.default;
            attic = inputs.attic.packages.${system}.default;
            colmena = inputs.colmena.packages.${system}.colmena;
            nixd = inputs.nixd.packages.${system}.default;
            keycloak-keywind = prev.pkgs.callPackage ../packages/keycloak-keywind { };
            nix-rfc-92 = inputs.nix-rfc-92.packages.${system}.default;
            bcachefs-tools = prev.unstable.bcachefs-tools;
            zotero = inputs.zotero.packages.${system}.default;
          })
      ];
    }
  ];
  extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
}

