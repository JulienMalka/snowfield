{ config, ... }:
{
  services.syncthing = {
    enable = true;
    user = "julien";
    group = "users";
    overrideDevices = true;
    overrideFolders = true;

    settings.options = {
      urAccepted = -1;
      listenAddresses = [ "tcp://${config.machine.meta.ips.vpn.ipv4}" ];
    };

    settings.devices = {
      "gustave" = {
        id = "6APF3EP-TIV7ZBK-5WB5SA4-Y2K37CR-AMIB2TM-6T2VORK-UYNQO2X-TO6V2QH";
        addresses = [
          "tcp://gustave.luj:22000"
        ];
      };

      "gallifrey" = {
        id = "P3BTFAX-4MCSFQB-C5R5YBP-YGMJ6FU-OKJN4QG-MJ2BV6Y-YB4U7VL-3GFSTAM";
        addresses = [
          "tcp://gallifrey.luj:22000"
        ];
      };

      "arcadia" = {
        id = "E5CGH2H-3XMMCKQ-5PTMKKA-4C4VDS3-JCBZGRM-4GTAWHQ-QRJ367E-BXFMUAU";
        addresses = [
          "tcp://arcadia.luj:22000"
        ];
      };

    };
    settings.folders = {
      "dev" = {
        path = "/home/julien/dev";
        settings.devices = [
          "gustave"
          "gallifrey"
          "arcadia"
        ];
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
