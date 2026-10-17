{
  config,
  lib,
  pkgs,
  ...
}:
let
  mailDir = "/var/lib/hermes/mail";
  credentials = "/run/credentials/hermes-mail-sync.service";

  # Julien's four Stalwart principals, mirrored the way his laptops do
  # (home-manager-modules/mails/mujmap.nix), so tags mean the same thing on
  # both sides. mujmap logs in as the principal it syncs, so these
  # credentials could send mail too: Jacques has no sending tool and
  # HERMES.md forbids it, nothing stronger.
  accounts = {
    malka = {
      principal = "malka";
      passwordCommand = "sed -n 's/^CALDAV_PASSWORD=//p' ${credentials}/caldav";
    };
    ens = {
      principal = "julien-ens";
      passwordCommand = "cat ${credentials}/mirrors";
    };
    tp = {
      principal = "julien-tp";
      passwordCommand = "cat ${credentials}/mirrors";
    };
    dgnum = {
      principal = "julien-dgnum";
      passwordCommand = "cat ${credentials}/mirrors";
    };
  };

  mujmapConfig =
    _: a:
    (pkgs.formats.toml { }).generate "mujmap.toml" {
      session_url = "https://mail.luj.fr/.well-known/jmap";
      username = a.principal;
      password_command = a.passwordCommand;
      concurrent_downloads = 8;
      timeout = 60;
      tags = {
        inbox = "inbox";
        sent = "sent";
        deleted = "deleted";
        spam = "spam";
        important = "important";
        phishing = "phishing";
      };
    };

  notmuchConfig = pkgs.writeText "notmuch-config" ''
    [database]
    path=${mailDir}
    [maildir]
    synchronize_flags=true
    [new]
    tags=
    [search]
    exclude_tags=deleted;spam
    [user]
    name=Julien Malka
    primary_email=julien@malka.sh
    other_email=luj@dgnum.eu;julien@geosurge.ai;jmalka@kth.se;julien.malka@telecom-paris.fr
  '';

  sync = pkgs.writeShellApplication {
    name = "hermes-mail-sync";
    runtimeInputs = [
      pkgs.bash
      pkgs.mujmap-patched
      pkgs.notmuch
      pkgs.gnused
      pkgs.coreutils
    ];
    text = ''
      ${lib.concatStrings (
        lib.mapAttrsToList (acct: a: ''
          install -d -m 0700 ${mailDir}/${acct}
          install -m 0600 ${mujmapConfig acct a} ${mailDir}/${acct}/mujmap.toml
        '') accounts
      )}
      if [ ! -d ${mailDir}/.notmuch ]; then
        notmuch new --quiet
      fi
      rc=0
      for acct in ${lib.concatStringsSep " " (lib.attrNames accounts)}; do
        mujmap -C ${mailDir}/$acct sync || rc=$?
      done
      exit $rc
    '';
  };
in
{
  environment.systemPackages = [ pkgs.notmuch ];
  environment.variables.NOTMUCH_CONFIG = "${notmuchConfig}";

  # The mail skill's draft.py stores drafts on the server for all four
  # principals, so the gateway carries the mirrors' password as well as
  # the CalDAV one it already has for malka.
  systemd.services.hermes-gateway = {
    path = [ pkgs.notmuch ];
    environment = {
      NOTMUCH_CONFIG = "${notmuchConfig}";
      MAIL_DIR = mailDir;
    };
    restartTriggers = [ config.age.secrets.hermes-mail-mirrors.file ];
    serviceConfig.LoadCredential = [ "mail-mirrors:${config.age.secrets.hermes-mail-mirrors.path}" ];
    script = lib.mkBefore ''
      export MAIL_MIRRORS_PASSWORD="$(< "$CREDENTIALS_DIRECTORY/mail-mirrors")"
    '';
  };

  systemd.services.hermes-mail-sync = {
    description = "mujmap sync of Julien's mail into Jacques' notmuch";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.NOTMUCH_CONFIG = "${notmuchConfig}";
    serviceConfig = {
      Type = "oneshot";
      User = "hermes";
      Group = "hermes";
      ExecStart = lib.getExe sync;
      LoadCredential = [
        "caldav:${config.age.secrets.hermes-caldav.path}"
        "mirrors:${config.age.secrets.hermes-mail-mirrors.path}"
      ];
      TimeoutStartSec = "6h";
    };
  };

  systemd.timers.hermes-mail-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitInactiveSec = "2min";
    };
  };

  # The password of Julien's julien-ens, julien-tp and julien-dgnum
  # principals, the one akhaten's mbsync writes with.
  age.secrets.hermes-mail-mirrors.file = ./hermes-mail-mirrors.age;
}
