{ config, lib, ... }:
let
  cfg = config.luj.programs.ssh-client;
in
with lib;
{
  options.luj.programs.ssh-client = {
    enable = mkEnableOption "Enable ssh client";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks =
        lib.mapAttrs (_: v: {
          hostname = if v.ips ? "vpn" then v.ips.vpn.ipv4 else v.ips.public.ipv4;
          user = v.sshUser;
          port = v.sshPort;
        }) lib.snowfield
        // {
          sas = {
            hostname = "sas.eleves.ens.fr";
            user = "jmalka";
          };
          router = {
            hostname = "vpn.saumon.network";
          };
          mails = {
            hostname = "192.168.0.76";
            proxyJump = "router";
          };

          proxy-telecom = {
            hostname = "ssh.enst.fr";
            user = "jmalka";
          };
          ferrari = {
            hostname = "195.154.212.97";
          };
          lame24 = {
            hostname = "lame24.enst.fr";
            user = "jmalka";
            proxyJump = "proxy-telecom";
          };

          epyc = {
            hostname = "epyc.infra.newtype.fr";
            user = "luj";
            proxyJump = "tower";
          };

          exps = {
            hostname = "192.168.0.240";
            proxyJump = "router";
          };

        };
    };
  };
}
