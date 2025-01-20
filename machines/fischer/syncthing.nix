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

    devices = {
      "gustave" = {
        id = "6APF3EP-TIV7ZBK-5WB5SA4-Y2K37CR-AMIB2TM-6T2VORK-UYNQO2X-TO6V2QH";
        addresses = [
          "tcp://gustave.luj:22000"
        ];
      };

    };
    folders = {
      "dev" = {
        path = "/home/julien/dev";
        devices = [
          "gustave"
        ];
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
