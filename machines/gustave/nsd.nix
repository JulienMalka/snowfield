{
  config,
  lib,
  nixosConfigurations,
  dnsLib,
  ...
}:
let
  zonesToList = lib.mapAttrsToList (name: value: { ${name} = value; });
  zonesFromConfig = lib.mkMerge (
    lib.fold (elem: acc: acc ++ (zonesToList elem.config.machine.meta.zones)) [ ] (
      lib.attrValues nixosConfigurations
    )
  );

  allowedDomains = [
    "luj.fr"
    "julienmalka.me"
    "malka.family"
    "luj"
    "malka.sh"
  ];

  isVPNDomain = domain: lib.dns.domainToZone [ "luj" ] domain != null;

  zonesFromSnowField = lib.fold (elem: acc: lib.attrsets.recursiveUpdate acc elem) { } (
    lib.flatten (
      map (
        elem:
        let
          domains = if builtins.hasAttr "subdomains" elem then elem.subdomains else [ ];
        in
        map (domain: {
          machine.meta.zones.${lib.dns.domainToZone allowedDomains domain}.subdomains =
            lib.dns.domainToRecords (lib.dns.getDomainPrefix allowedDomains domain) elem
              (isVPNDomain domain);
        }) domains

      ) (lib.attrValues lib.snowfield)
    )
  );

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

lib.mkMerge [
  {
    services.nsd = {
      enable = true;
      interfaces = [
        config.machine.meta.ips.vpn.ipv4
        config.machine.meta.ips.vpn.ipv6
        config.machine.meta.ips.public.ipv6
      ];
      zones = lib.mapAttrs (_: value: {
        data = builtins.toString value;
        provideXFR = [
          "100.100.45.0/24 NOKEY"
          "fd7a:115c:a1e0::1/128 NOKEY"
        ];
        notify = [
          "${lib.snowfield.akhaten.ips.vpn.ipv4} NOKEY"
          "fd7a:115c:a1e0::1 NOKEY"
        ];
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
      for file in ${stateDir}/zones/*; do
        sed -i "3s/0/$new_value/" "$file"
      done
    '';

    networking.firewall.allowedUDPPorts = [ 53 ];

    machine.meta.zones."luj.fr".A = [ config.machine.meta.ips.public.ipv4 ];
    machine.meta.zones."luj.fr".AAAA = [ config.machine.meta.ips.public.ipv6 ];
    machine.meta.zones."luj.fr".TXT = [ "homepage.luj.luj-static.page" ];

  }

  # DNS Records from all non local configurations are exported here
  zonesFromSnowField
]
