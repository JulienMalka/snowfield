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

  minimalZone = {
    SOA = {
      nameServer = "ns";
      adminEmail = "dns@julienmalka.me";
      serial = 0;
    };
  };

in

{
  services.nsd = {
    enable = true;
    remoteControl.enable = true;
    interfaces = [
      config.machine.meta.ips.public.ipv4
      config.machine.meta.ips.vpn.ipv4
    ];
    zones = lib.mapAttrs (name: _: {
      requestXFR = [ "AXFR ${lib.snowfield.gustave.ips.vpn.ipv4} NOKEY" ];
      allowNotify = [ "${lib.snowfield.gustave.ips.vpn.ipv4} NOKEY" ];
      data = dnsLib.toString name minimalZone;
    }) (evalZones zonesFromConfig);
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
