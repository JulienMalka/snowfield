{ lib, config, ... }:
let
  cfg = config.luj.deployment;
  meta = config.machine.meta;
in
{

  options.luj.deployment.enable = lib.mkEnableOption "activate deployment on machine";

  config = lib.mkIf cfg.enable {

    deployment = {
      targetHost = lib.mkDefault meta.ips.vpn.ipv4;
      targetPort = lib.mkDefault meta.sshPort;
      targetUser = lib.mkDefault "root";
      allowLocalDeployment = lib.mkDefault true;
      buildOnTarget = lib.mkDefault true;
    };

  };
}
