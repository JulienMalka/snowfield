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
        id = "GVKWXUD-UVEXZMZ-YCZ7S6X-R47ZWG4-AJQ2XAQ-B3HUDTK-NZTBJ2E-EFXGAQX";
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
