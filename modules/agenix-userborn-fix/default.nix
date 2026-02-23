{
  config,
  pkgs,
  lib,
  ...
}:

let
  sysusersEnabled =
    (config.systemd.sysusers.enable or false) || (config.services.userborn.enable or false);
in
{
  config = lib.mkIf (sysusersEnabled && config.age.secrets != { }) {
    systemd.services.agenix-install-secrets = {
      after = lib.mkForce [ ];
      before = [ "systemd-sysusers.service" ];
    };

    systemd.services.agenix-chown = {
      wantedBy = [ "sysinit.target" ];
      after = [
        "systemd-sysusers.service"
        "agenix-install-secrets.service"
      ];
      requires = [ "agenix-install-secrets.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          let
            chownSecret = _: secret: ''
              chown ${secret.owner}:${secret.group} "${secret.path}" || true
              chmod ${secret.mode} "${secret.path}" || true
            '';
          in
          pkgs.writeShellScript "agenix-chown" ''
            ${lib.concatStrings (lib.mapAttrsToList chownSecret config.age.secrets)}
            true
          '';
      };
    };
  };
}
