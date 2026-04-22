inputs: profiles: dnsLib: final: _prev:

let
  inherit (builtins)
    readDir
    toString
    functionArgs
    ;
  inherit (final)
    filterAttrs
    mapAttrs
    mapAttrs'
    nameValuePair
    ;
  inherit (final.strings) hasSuffix removeSuffix;

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
  # Imports every subdirectory of `path` by name, expecting each to contain a
  # `default.nix`. Returns `{ dirname = import path/dirname/default.nix; }`.
  importDir =
    path:
    mapAttrs (name: _: import (path + "/${name}")) (
      filterAttrs (_: v: v == "directory") (readDir path)
    );

  # Imports every `.nix` file in `path` (non-recursive). Returns
  # `{ basename = import path/basename.nix; }` with the `.nix` suffix stripped.
  importNixFiles =
    path:
    mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) (import (path + "/${name}"))) (
      filterAttrs (name: v: v == "regular" && hasSuffix ".nix" name) (readDir path)
    );

  # Alias kept for readability — the caller is importing machine configs.
  importConfig = importDir;

  # Service modules use these to advertise themselves as an nginx vhost on both
  # the public zone (`julienmalka.me`) and the VPN zone (`luj`).
  mkSubdomain = name: port: {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."${name}.julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${toString port}";
    };
  };

  mkVPNSubdomain = name: port: {
    luj.nginx.enable = true;
    services.nginx.virtualHosts."${name}.luj" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:${toString port}";
    };
  };

  # Group a list of `{ name; value }` by name and merge the values via `//`.
  # Used by `mapAttrsWithMerge`, which `lib.dns` relies on to fold DNS records.
  listToAttrsWithMerge =
    l:
    mapAttrs (_: v: _prev.foldr (elem: acc: elem.value // acc) { } v) (builtins.groupBy (e: e.name) l);

  mapAttrsWithMerge =
    f: set: listToAttrsWithMerge (map (attr: f attr set.${attr}) (builtins.attrNames set));

  # Recursive `//` that concatenates list values (instead of replacing them)
  # when the same key exists on both sides. Used by `collectSecrets` to fold
  # `age.secrets` across machines while keeping per-secret `targets` lists.
  # `lib.recursiveUpdate` would drop entries here, so we keep a custom impl.
  deepMerge =
    lhs: rhs:
    lhs
    // rhs
    // mapAttrs (
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
    ) rhs;

  # Evaluate `machine.meta` for every host in `machines/` plus every external
  # machine declared in `lib/snowfield.nix`. The `null`-arg trick below feeds
  # the machine's function just enough to let it return without running NixOS
  # module evaluation — we only want its `machine.meta` attrset.
  snowfield =
    mapAttrs (
      name: _:
      let
        machineF = import (../machines + "/${name}/default.nix");
      in
      evalMeta
        (machineF (mapAttrs (_: _: null) (functionArgs machineF) // { inherit inputs profiles; }))
        .machine.meta
    ) (filterAttrs (_: v: v == "directory") (readDir ../machines))
    // mapAttrs (_: evalMeta) non_local_machines;

  dns = import ./dns.nix {
    lib = final;
    inherit dnsLib;
  };

  mkMachine = import ./mkmachine.nix inputs final;

  inherit (import ./secrets.nix final) collectSecrets;
}
