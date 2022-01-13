inputs: final: prev:

with builtins; with inputs;

let
  overlay-unstable = final: prev: {
    unstable = unstable.legacyPackages.x86_64-linux;
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
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        nixpkgs.overlays = [
          overlay-unstable
          (final: prev:
            {
              tinystatus = prev.pkgs.callPackage ../packages/tinystatus { };
              mosh = prev.pkgs.callPackage ../packages/mosh { };
              htpdate = prev.pkgs.callPackage ../packages/htpdate { };
            })
          inputs.neovim-nightly-overlay.overlay
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

}

