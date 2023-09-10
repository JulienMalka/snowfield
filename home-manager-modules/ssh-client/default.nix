{ config, pkgs, lib, ... }:
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
      matchBlocks = lib.mapAttrs
        (n: v: { hostname = "${n}.${lib.luj.tld}"; user = v.sshUser; port = v.sshPort; })
        lib.luj.machines // {
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
