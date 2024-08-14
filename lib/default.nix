inputs: profiles: final: _prev:

with builtins;
let
  evalMeta =
    raw:
    (_prev.evalModules {
      modules = [
        (import ../modules/meta/default.nix)
        { machine.meta = raw; }
      ];
      specialArgs = {
        inherit profiles;
      };
    }).config.machine.meta;

  non_local_machines = (import ./snowfield.nix).machines;
in
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

  listToAttrsWithMerge =
    l:
    mapAttrs (_: v: _prev.fold (elem: acc: elem.value // acc) { } v) (builtins.groupBy (e: e.name) l);

  mapAttrsWithMerge = f: set: listToAttrsWithMerge (map (attr: f attr set.${attr}) (attrNames set));

  snowfield =
    (mapAttrs (
      name: _value:
      let
        machineF = import (../machines + "/${name}/default.nix");
      in
      evalMeta
        (machineF ((mapAttrs (_: _: null) (builtins.functionArgs machineF)) // { inherit inputs; }))
        .machine.meta
    ) (final.filterAttrs (_: v: v == "directory") (readDir ../machines)))
    // mapAttrs (_: evalMeta) non_local_machines;

  dns = import ./dns.nix {
    lib = final;
    dnsLib = (import inputs.dns).lib;
  };

}
