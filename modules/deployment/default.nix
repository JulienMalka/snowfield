{ lib, config, ... }:
with lib;
let
  cfg = config.luj.deployment;
  hostname = config.networking.hostName;
in
{

  options.luj.deployment.enable = mkEnableOption "activate deployment on machine";

  config = mkIf cfg.enable {

    deployment = {
      targetHost = lib.mkDefault "${hostname}.${config.machine.meta.tld}";
      targetPort = lib.mkDefault 45;
      targetUser = lib.mkDefault "root";
      allowLocalDeployment = lib.mkDefault true;
      buildOnTarget = lib.mkDefault true;
    };

  };
}
