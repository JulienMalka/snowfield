inputs: final: prev:

with builtins;

let
  overlay-unstable = arch: final: prev: {
    unstable = inputs.unstable.legacyPackages."${arch}";
    stable = inputs.nixpkgs.legacyPackages."${arch}";
  };
in
{

  mkMachine = { host, host-config, modules, nixpkgs ? inputs.nixpkgs, system ? "x86_64-linux", home-manager ? inputs.home-manager }: nixpkgs.lib.nixosSystem {
    lib = final;
    system = system;
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ../base.nix
      inputs.sops-nix.nixosModules.sops
      host-config
      home-manager.nixosModules.home-manager
      inputs.simple-nixos-mailserver.nixosModule
      inputs.hyprland.nixosModules.default
      inputs.attic.nixosModules.atticd
      {
        home-manager.useGlobalPkgs = true;
        nixpkgs.overlays = [
          (overlay-unstable system)
          (final: prev:
            {
              hyprland = inputs.hyprland.packages.${system}.default.override {
                enableXWayland = true;
                hidpiXWayland = true;
                nvidiaPatches = false;
                legacyRenderer = true;
              };
              waybar = prev.waybar.overrideAttrs (oldAttrs: {
                mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
              });
              tinystatus = prev.pkgs.callPackage ../packages/tinystatus { };
              zotero = prev.pkgs.callPackage ../packages/zotero { };
              jackett = prev.unstable.jackett;
              radarr = prev.unstable.radarr;
              flaresolverr = prev.pkgs.callPackage ../packages/flaresolverr { };
              htpdate = prev.pkgs.callPackage ../packages/htpdate { };
              authelia = prev.pkgs.callPackage ../packages/authelia { };
              paperless-ng = prev.pkgs.callPackage ../packages/paperless-ng { };
              tailscale = prev.unstable.tailscale;
              nodePackages = prev.unstable.nodePackages;
              hydrasect = prev.pkgs.callPackage ../packages/hydrasect { };
              uptime-kuma = prev.pkgs.callPackage ../packages/uptime-kuma { };
              buildbot-badges = prev.pkgs.callPackage ../packages/buildbot-badges { };
              linkal = inputs.linkal.defaultPackage."${system}";
              mosh = prev.unstable.mosh;
              hyprpaper = inputs.hyprpaper.packages.${system}.default;
              attic = inputs.attic.packages.${system}.default;
            })
        ];
      }
    ];
  };

  importConfig = path: (mapAttrs (name: value: import (path + "/${name}/default.nix")) (readDir path));

  mkSubdomain = name: port: {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."${name}.julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };
  };

  mkVPNSubdomain = name: port: {
    luj.nginx.enable = true;
    security.acme.certs."${name}.luj".server = "https://ca.luj:8444/acme/acme/directory";
    services.nginx.virtualHosts."${name}.luj" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          allow 100.10.10.0/8;
          deny all;
        '';
      };
    };
  };




  luj = import ./luj.nix inputs final;

}

