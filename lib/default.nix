inputs: profiles: dnsLib: final: _prev:

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
  discovery = import ./discovery.nix { lib = final; };

  importConfig =
    path:
    (mapAttrs (name: _value: import (path + "/${name}/default.nix")) (discovery.directories path));

  listToAttrsWithMerge =
    l:
    mapAttrs (_: v: _prev.foldr (elem: acc: elem.value // acc) { } v) (builtins.groupBy (e: e.name) l);

  mapAttrsWithMerge = f: set: listToAttrsWithMerge (map (attr: f attr set.${attr}) (attrNames set));

  deepMerge =
    lhs: rhs:
    lhs
    // rhs
    // (builtins.mapAttrs (
      rName: rValue:
      let
        lValue = lhs.${rName} or null;
      in
      if builtins.isAttrs lValue && builtins.isAttrs rValue then
        deepMerge lValue rValue
      else if builtins.isList lValue && builtins.isList rValue then
        lValue ++ rValue
      else
        rValue
    ) rhs);

  snowfield =
    (mapAttrs (
      name: _value:
      let
        machineF = import (../machines + "/${name}/default.nix");
      in
      evalMeta
        (machineF (
          (mapAttrs (_: _: null) (builtins.functionArgs machineF)) // { inherit inputs profiles; }
        )).machine.meta
    ) (discovery.directories ../machines))
    // mapAttrs (_: evalMeta) non_local_machines;

  dns = import ./dns.nix {
    lib = final;
    inherit dnsLib;
  };

  mkMachine = import ./mkmachine.nix inputs final;

}
