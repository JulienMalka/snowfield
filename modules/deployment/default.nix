{ lib, config, ... }:
with lib;
let
  cfg = config.luj.deployment;
in
{

  options.luj.deployment.enable = mkEnableOption "activate deployment on machine";

  config = mkIf cfg.enable {

    deployment = {
      targetHost = lib.mkDefault config.machine.meta.ips.vpn.ipv4;
      targetPort = lib.mkDefault 45;
      targetUser = lib.mkDefault "root";
      allowLocalDeployment = lib.mkDefault true;
      buildOnTarget = lib.mkDefault true;
    };

  };
}
