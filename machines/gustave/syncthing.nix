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
      "fischer" = {
        id = "XEPZZIP-GX73OKE-KNGZA47-XWWGI5G-LNXPU57-BMLXK5M-VNGS5UQ-ZFIZSAK";
      };
    };
    folders = {
      "dev" = {
        path = "/home/julien/dev";
        devices = [
          "fischer"
        ];
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
