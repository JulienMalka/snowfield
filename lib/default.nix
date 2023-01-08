inputs: final: prev:

with builtins; with inputs;

let
  overlay-unstable = arch: final: prev: {
    unstable = unstable.legacyPackages."${arch}";
  };
in
{

  mkMachine = { host, host-config, modules, system ? "x86_64-linux" }: nixpkgs.lib.nixosSystem {
    lib = final;
    system = system;
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ../base.nix
      sops-nix.nixosModules.sops
      host-config
      home-manager.nixosModules.home-manager
      simple-nixos-mailserver.nixosModule
      {
        home-manager.useGlobalPkgs = true;
        nixpkgs.overlays = [
          (overlay-unstable system)
          (final: prev:
            {
              tinystatus = prev.pkgs.callPackage ../packages/tinystatus { };
              jackett = prev.unstable.jackett;
              radarr = prev.unstable.radarr;
              flaresolverr = prev.pkgs.callPackage ../packages/flaresolverr { };
              htpdate = prev.pkgs.callPackage ../packages/htpdate { };
              authelia = prev.pkgs.callPackage ../packages/authelia { };
              paperless-ng = prev.pkgs.callPackage ../packages/paperless-ng { };
              tailscale = prev.unstable.tailscale;
              nodePackages = prev.unstable.nodePackages;
              linkal = inputs.linkal.defaultPackage."${system}";
              mosh = prev.unstable.mosh;
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




  luj = import ./luj.nix final;

}

