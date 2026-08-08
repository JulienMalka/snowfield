{
  config,
  lib,
  pkgs,
  ...
}:
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

      settings =
        lib.mapAttrs (name: v: {
          HostName = if v.ips ? "vpn" then v.ips.vpn.ipv4 else v.ips.public.ipv4;
          User = v.sshUser;
          Port = v.sshPort;
          HostKeyAlias = "${name}.luj";
          ProxyCommand = "${pkgs.step-cli}/bin/step ssh proxycommand --provisioner 'Luj SSO' --ca-url ${caConfig.stepCAUrl} --root /etc/step/certs/root_ca.crt %r %h %p";
        }) lib.snowfield
        // {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/known_hosts_ca";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
          sas = {
            HostName = "sas.eleves.ens.fr";
            User = "jmalka";
          };
          router = {
            HostName = "vpn.saumon.network";
          };
          mails = {
            HostName = "192.168.0.76";
            ProxyJump = "router";
          };

          proxy-telecom = {
            HostName = "ssh.enst.fr";
            User = "jmalka";
          };
          ferrari = {
            HostName = "195.154.212.97";
          };
          lame24 = {
            HostName = "lame24.enst.fr";
            User = "jmalka";
            ProxyJump = "proxy-telecom";
          };

          epyc = {
            HostName = "epyc.infra.newtype.fr";
            User = "luj";
            ProxyJump = "tower";
          };

          exps = {
            HostName = "192.168.0.240";
            ProxyJump = "router";
          };

        };
    };
  };
}
