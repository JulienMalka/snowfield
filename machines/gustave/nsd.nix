{
  config,
  lib,
  inputs,
  nixosConfigurations,
  ...
}:
let
  zonesToList = lib.mapAttrsToList (name: value: { ${name} = value; });
  zonesFromConfig = lib.mkMerge (
    lib.fold (elem: acc: acc ++ (zonesToList elem.config.machine.meta.zones)) [ ] (
      lib.attrValues nixosConfigurations
    )
  );
  dnsLib = (import inputs.dns).lib;
  evalZones =
    zones:
    (lib.evalModules {
      modules = [
        {
          options = {
            zones = lib.mkOption {
              type = lib.types.attrsOf dnsLib.types.zone;
              description = "DNS zones";
            };
          };
          config = {
            inherit zones;
          };
        }
      ];
    }).config.zones;

in

{
  services.nsd = {
    enable = true;
    interfaces = [
      config.machine.meta.ips.public.ipv4
      config.machine.meta.ips.public.ipv6
    ];
    zones = lib.mapAttrs (_: value: {
      data = builtins.toString value;
      provideXFR = [ "100.100.45.0/24 NOKEY" ];
    }) (evalZones zonesFromConfig);
  };
}
