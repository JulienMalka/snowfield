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
      simple-nixos-mailserver.nixosModule
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        nixpkgs.overlays = [
          overlay-unstable
          (final: prev:
            {
              tinystatus = prev.pkgs.callPackage ../packages/tinystatus { };
              mosh = prev.pkgs.callPackage ../packages/mosh { };
              flaresolverr = prev.pkgs.callPackage ../packages/flaresolverr { };
              htpdate = prev.pkgs.callPackage ../packages/htpdate { };
              authelia = prev.pkgs.callPackage ../packages/authelia { };
              paperless-ng = prev.pkgs.callPackage ../packages/paperless-ng { };
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

  mkPrivateSubdomain = name: port: {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."${name}.julienmalka.me" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          allow 10.100.0.0/24;
          deny all;
        '';
      };
    };
  };

  mkVPNSubdomain = name: port: {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."${name}.luj" = {
      sslCertificate = "/etc/nginx/certs/subdomains/cert.pem";
      sslCertificateKey = "/etc/nginx/certs/subdomains/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          allow 10.100.0.0/24;
          deny all;
        '';
      };
    };
  };




  luj = import ./luj.nix final;

}

