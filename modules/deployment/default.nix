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
      targetHost = "${hostname}.${config.machine.meta.tld}";
      targetPort = 45;
      targetUser = "root";
      allowLocalDeployment = true;
      buildOnTarget = true;
    };

  };
}
