{ config, lib, ... }:
let
  cfg = config.luj.programs.ssh-client;
  caConfig = import ../../lib/ca-config.nix;
in
with lib;
{
  options.luj.programs.ssh-client = {
    enable = mkEnableOption "Enable ssh client";
  };

  config = mkIf cfg.enable {
    home.file.".ssh/known_hosts_ca".text =
      let
        fleetHosts = builtins.attrNames lib.snowfield;
        patterns = [ "*.luj" ] ++ fleetHosts;
      in
      ''
        @cert-authority ${lib.concatStringsSep "," patterns} ${caConfig.sshHostCAPublicKey}
      '';

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks =
        lib.mapAttrs (name: v: {
          hostname = if v.ips ? "vpn" then v.ips.vpn.ipv4 else v.ips.public.ipv4;
          user = v.sshUser;
          port = v.sshPort;
          extraOptions.HostKeyAlias = "${name}.luj";
          proxyCommand = "step ssh proxycommand --provisioner 'Luj SSO' --ca-url ${caConfig.stepCAUrl} --root /etc/step/certs/root_ca.crt %r %h %p";
        }) lib.snowfield
        // {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/known_hosts_ca";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
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
