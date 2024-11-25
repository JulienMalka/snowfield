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
    programs.mbsync.enable = true;
    programs.mbsync.package = pkgs.stable.isync;
    programs.msmtp.enable = true;
    accounts.email = {
      accounts.ens = {
        folders.inbox = "INBOX";
        address = "julien.malka@ens.fr";
        imap.host = "clipper.ens.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = true;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/julien/.config/ens-mail-pw";
        smtp = {
          host = "clipper.ens.fr";
        };
        userName = "jmalka";
      };
      accounts.work = {
        folders.inbox = "INBOX";
        address = "julien@malka.sh";
        imap.host = "mail.luj.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/julien/.config/work-mail-pw";
        smtp = {
          host = "mail.luj.fr";
        };
        userName = "malka";
      };

      accounts.telecom = {
        folders.inbox = "INBOX";
        address = "julien.malka@telecom-paris.fr";
        imap.host = "z.imt.fr";
        mbsync = {
          enable = true;
          create = "maildir";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/julien/.config/telecom-mail-pw";
        smtp = {
          host = "z.imt.fr";
        };
        userName = "julien.malka@telecom-paris.fr";
      };

      accounts.dgnum = {
        folders.inbox = "INBOX";
        address = "luj@dgnum.eu";
        imap.host = "kurisu.lahfa.xyz";
        mbsync = {
          enable = true;
          create = "maildir";
          extraConfig.channel = {
            "CopyArrivalDate" = "yes";
          };
        };
        msmtp.enable = true;
        primary = false;
        realName = "Julien Malka";
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/julien/.config/dgnum-mail-pw";
        smtp = {
          host = "kurisu.lahfa.xyz";
        };
        userName = "luj@dgnum.eu";
      };

    };

    services.mbsync = {
      enable = true;
      frequency = "minutely";
      verbose = true;
    };

  };
}
