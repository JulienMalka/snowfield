{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  syncthing_configured = lib.filterAttrs (
    n: v: n != config.networking.hostName && lib.hasAttr "syncthing" v
  ) lib.snowfield;

in
{

  disabledModules = [
    "${inputs.nixpkgs}/nixos/modules/services/networking/syncthing.nix"
  ];

  imports = [
    "${inputs.unstable}/nixos/modules/services/networking/syncthing.nix"
  ];

  services.syncthing = {
    enable = true;
    package = pkgs.unstable.syncthing;
    key = config.age.secrets."syncthing-key".path;
    cert = config.age.secrets."syncthing-cert".path;
    user = "julien";
    group = "users";
    overrideDevices = true;
    overrideFolders = true;

    settings.options = {
      urAccepted = -1;
      listenAddresses = [ "tcp://${config.machine.meta.ips.vpn.ipv4}" ];
    };

    settings.devices = lib.mapAttrs (_: v: {
      inherit (v.syncthing) id;
      addresses = [ "tcp://${v.ips.vpn.ipv4}:22000" ];
    }) syncthing_configured;

    settings.folders = {
      "dev" = {
        path = "/home/julien/dev";
        ignorePatterns = [
          "nixpkgs"
          "target"
        ];
        settings.devices = lib.attrNames syncthing_configured;
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

  age.secrets."syncthing-key".file =
    ../machines/${config.networking.hostName}/secrets/syncthing-key.age;

  age.secrets."syncthing-cert".file =
    ../machines/${config.networking.hostName}/secrets/syncthing-cert.age;

}
