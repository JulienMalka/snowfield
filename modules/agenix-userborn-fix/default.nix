# Re-orders agenix systemd services around systemd-sysusers.
#
# agenix-install-secrets normally runs `After=sysinit.target` and chowns secrets
# to target users. When `systemd.sysusers` or `services.userborn` is enabled,
# those users are created by systemd-sysusers.service (which itself runs early
# in sysinit.target), so the chown races and agenix picks up nonexistent uids.
# See agenix#236 and the associated nixpkgs discussion.
#
# Workaround: install secrets before sysusers, then chown them in a dedicated
# service that waits for sysusers to finish. Drop this module once agenix ships
# a native fix (the `systemd.services.agenix-install-secrets` override is the
# load-bearing piece to delete first).
#
# Activates only when one of the two user-creation services is enabled and the
# machine actually declares agenix secrets — other hosts get an empty config.
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
