{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.luj.emails;
in
with lib;
{
  options.luj.emails = {
    enable = mkEnableOption "enable mail management";
  };

  config = mkIf cfg.enable {

    age.secrets.work-mail-pw = {
      file = ../../private/secrets/work-mail-pw.age;
    };

    age.secrets.dgnum-mail-pw = {
      file = ../../private/secrets/dgnum-mail-pw.age;
    };

    age.secrets.telecom-mail-pw = {
      file = ../../private/secrets/telecom-mail-pw.age;
    };

    age.secrets.ens-mail-pw = {
      file = ../../private/secrets/ens-mail-pw.age;
    };

    programs.mbsync = {
      enable = lib.mkDefault true;
      package = pkgs.unstable.isync;
    };

    programs.msmtp.enable = true;
    accounts.email = {
      accounts.ens = {
        notmuch.enable = true;
        folders.inbox = "INBOX";
        address = "julien.malka@ens.fr";
        imap.host = "clipper.ens.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = true;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.ens-mail-pw.path}";
        smtp = {
          host = "clipper.ens.fr";
        };
        userName = "jmalka";
      };
      accounts.work = {
        notmuch.enable = true;
        folders.inbox = "INBOX";
        address = "julien@malka.sh";
        imap.host = "mail.luj.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.work-mail-pw.path}";
        smtp = {
          host = "mail.luj.fr";
        };
        userName = "malka";
      };

      accounts.telecom = {
        notmuch.enable = true;
        folders.inbox = "INBOX";
        address = "julien.malka@telecom-paris.fr";
        imap.host = "z.imt.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.telecom-mail-pw.path}";
        smtp = {
          host = "z.imt.fr";
        };
        userName = "julien.malka@telecom-paris.fr";
      };

      accounts.dgnum = {
        notmuch.enable = true;
        folders.inbox = "INBOX";
        address = "luj@dgnum.eu";
        imap.host = "kurisu.lahfa.xyz";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.dgnum-mail-pw.path}";
        smtp = {
          host = "kurisu.lahfa.xyz";
        };
        userName = "luj@dgnum.eu";
      };

    };

    services.mbsync = {
      enable = lib.mkDefault true;
      frequency = "minutely";
      package = pkgs.unstable.isync;
    };

    services.mbsync.postExec = lib.mkDefault "${pkgs.notmuch}/bin/notmuch new";

    programs.notmuch = {
      enable = lib.mkDefault true;
      new.tags = [ "new" ];
      hooks.preNew = lib.mkDefault ''
        ${pkgs.notmuch-mailmover}/bin/notmuch-mailmover --config ${./mailmover.lua}
      '';
      hooks.postNew = lib.mkDefault ''
        ${pkgs.afew}/bin/afew --tag --new
      '';
    };

    programs.afew = {
      enable = true;
      extraConfig = ''
        [FolderNameFilter]
        maildir_separator = /
        folder_lowercases = true
        [Filter.1]
        query = tag:new
        tags = -new
      '';
    };

  };
}
