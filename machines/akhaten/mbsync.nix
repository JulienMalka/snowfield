{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = "mbsync-akhaten";
  group = "mbsync-akhaten";
  stateDir = "/var/lib/mbsync-akhaten";

  mirrorPass = config.age.secrets.julien-mirrors-stalwart-pw.path;

  accounts = {
    telecom = {
      sourceHost = "z.imt.fr";
      sourceUser = "julien.malka@telecom-paris.fr";
      sourcePass = config.age.secrets.telecom-mail-pw.path;
      principal = "julien-tp";
      principalPass = mirrorPass;
    };
    dgnum = {
      sourceHost = "kurisu.lahfa.xyz";
      sourceUser = "luj@dgnum.eu";
      sourcePass = config.age.secrets.dgnum-mail-pw.path;
      principal = "julien-dgnum";
      principalPass = mirrorPass;
    };
  };

  mkChannel = name: a: ''
    IMAPAccount ${name}-source
    Host ${a.sourceHost}
    User ${a.sourceUser}
    PassCmd "cat ${a.sourcePass}"
    TLSType IMAPS
    Port 993

    IMAPStore ${name}-source-imap
    Account ${name}-source

    IMAPAccount ${name}-stalwart
    Host localhost
    User ${a.principal}
    PassCmd "cat ${a.principalPass}"
    TLSType None
    Port 143

    IMAPStore ${name}-stalwart-imap
    Account ${name}-stalwart

    Channel ${name}
    Far :${name}-source-imap:
    Near :${name}-stalwart-imap:
    # IMAP-to-IMAP sync needs to SELECT each listed mailbox on both ends,
    # unlike gustave's old IMAP-to-Maildir setup which only listed source.
    # Some upstream IMAP servers (z.imt.fr, kurisu.lahfa.xyz) advertise
    # Outlook-style \Noselect placeholder mailboxes (Deleted Items, Junk Mail)
    # that mbsync tries to open and fails on. Exclude them.
    #
    # Upstream `Trash` and `Junk` are also excluded: Stalwart's
    # auto-created role:trash / role:junk mailboxes are named "Deleted Items"
    # and "Junk Mail" and cannot be reassigned (server-enforced). Mirroring
    # upstream Trash into a literal "Trash" mailbox creates a split view
    # where mujmap's `+deleted` lands in one folder and upstream-mirrored
    # deletions in another. Dropping the mirror collapses to a single
    # role-mailbox per principal; old upstream trash isn't visible here, but
    # mujmap deletions still work correctly.
    Patterns "*" "!Deleted Items" "!Junk Mail" "!Sent Items" "!Trash" "!Junk"
    Sync Pull
    Expunge None
    Create Near
    # Stalwart's IMAP doesn't support in-mailbox SyncState files; store
    # state per-channel in a dedicated subdirectory of stateDir. The
    # per-channel subdir is critical: without it, mailbox names like
    # `Archive` and `INBOX` collide across channels (ens vs telecom vs
    # dgnum) and stomp each other.
    SyncState ${stateDir}/${name}/
    CopyArrivalDate yes
  '';

  mbsyncrc = pkgs.writeText "mbsyncrc-akhaten" (
    lib.concatMapStringsSep "\n" (n: mkChannel n accounts.${n}) (lib.attrNames accounts)
  );
in
{
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
    home = stateDir;
    createHome = false;
  };
  users.groups.${group} = { };

  age.secrets = {
    ens-mail-pw = {
      file = ../../home-manager-modules/mails/ens-mail-pw.age;
      owner = user;
      inherit group;
    };
    telecom-mail-pw = {
      file = ../../home-manager-modules/mails/telecom-mail-pw.age;
      owner = user;
      inherit group;
    };
    dgnum-mail-pw = {
      file = ../../home-manager-modules/mails/dgnum-mail-pw.age;
      owner = user;
      inherit group;
    };
    julien-mirrors-stalwart-pw = {
      file = ./julien-mirrors-stalwart-pw.age;
      owner = user;
      inherit group;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0700 ${user} ${group} - -"
  ];

  systemd.services.mbsync-akhaten = {
    description = "Mirror external IMAP into local Stalwart";
    after = [
      "network-online.target"
      "stalwart-mail.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = group;
      # TODO: Remove when post 1.5.1 is in stable
      ExecStart = "${pkgs.unstable.isync}/bin/mbsync --config ${mbsyncrc} --all";
      WorkingDirectory = stateDir;
      ProtectSystem = "strict";
      ReadWritePaths = [ stateDir ];
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
    };
  };

  systemd.timers.mbsync-akhaten = {
    description = "Periodic external IMAP -> Stalwart mirror";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      RandomizedDelaySec = "30s";
      Persistent = true;
    };
  };

  services.backup.includes = [ stateDir ];
}
