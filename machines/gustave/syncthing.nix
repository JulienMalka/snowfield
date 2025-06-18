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
      "fischer" = {
        id = "PLIMD3Z-L4DYKDB-MY4PFTS-3RMQUNF-GFWFOBB-SELW6MB-WIQJ2LM-QAC45QQ";
        addresses = [
          "tcp://fischer.luj:22000"
        ];
      };
      "gallifrey" = {
        id = "P3BTFAX-4MCSFQB-C5R5YBP-YGMJ6FU-OKJN4QG-MJ2BV6Y-YB4U7VL-3GFSTAM";
        addresses = [
          "tcp://gallifrey.luj:22000"
        ];
      };
    };
    settings.folders = {
      "dev" = {
        path = "/home/julien/dev";
        settings.devices = [
          "fischer"
          "gallifrey"
        ];
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  environment.persistence."/persistent".directories = [
    {
      directory = "/home/julien/dev";
      user = "julien";
      group = "users";
    }
  ];

}
