inputs: final: _prev:

with builtins;

rec {
  importConfig =
    path:
    (mapAttrs (name: _value: import (path + "/${name}/default.nix")) (
      final.filterAttrs (_: v: v == "directory") (readDir path)
    ));

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
    security.acme.certs."${name}.luj".server = "https://ca.luj/acme/acme/directory";
    services.nginx.virtualHosts."${name}.luj" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          allow 100.100.45.0/24;
          allow fd7a:115c:a1e0::/48;
          deny all;
        '';
      };
    };
  };

  evalMeta =
    raw:
    (_prev.evalModules {
      modules = [
        (import ../modules/meta/default.nix)
        { machine.meta = raw; }
      ];
    }).config.machine.meta;

  snowfield = mapAttrs (
    name: _value:
    evalMeta
      (import (../machines + "/${name}/default.nix") {
        inherit inputs;
        config = null;
        pkgs = null;
        lib = null;
        modulesPath = null;
      }).machine.meta
  ) (final.filterAttrs (_: v: v == "directory") (readDir ../machines));

  dns = import ./dns.nix {
    lib = final;
    dnsLib = (import inputs.dns).lib;
  };
}
