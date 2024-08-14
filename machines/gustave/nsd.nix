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

  stateDir = "/var/lib/nsd";

in

{
  services.nsd = {
    enable = true;
    interfaces = [
      config.machine.meta.ips.vpn.ipv4
      config.machine.meta.ips.public.ipv6
    ];
    zones = lib.mapAttrs (_: value: {
      data = builtins.toString value;
      provideXFR = [ "100.100.45.0/24 NOKEY" ];
      notify = [ "${lib.snowfield.akhaten.ips.vpn.ipv4} NOKEY" ];
    }) (evalZones zonesFromConfig);
  };

  systemd.services.nsd.preStart = lib.mkAfter ''
    if [ -f ${stateDir}/counter ]; then
      current_value=$(cat ${stateDir}/counter)
      new_value=$((current_value + 1))
      echo "$new_value" > ${stateDir}/counter
    else
      echo "0" > ${stateDir}/counter
      new_value="0"
    fi
    sed -i "3s/0/$new_value/" ${stateDir}/zones/julienmalka.me
  '';

  networking.firewall.allowedUDPPorts = [ 53 ];

}
