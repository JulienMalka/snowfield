{
  pkgs,
  config,
  lib,
  inputs,
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

  imports = [
    "${inputs.snowfield-private}/private-mail.nix"
    ./mujmap.nix
  ];

  config = mkIf cfg.enable {

    age.secrets.geosurge-mail-pw = {
      file = lib.mkForce ./geosurge-mail-pw.age;
    };

    age.secrets.work-mail-pw = {
      file = ./work-mail-pw.age;
    };

    age.secrets.dgnum-mail-pw = {
      file = ./dgnum-mail-pw.age;
    };

    age.secrets.telecom-mail-pw = {
      file = ./telecom-mail-pw.age;
    };

    age.secrets.ens-mail-pw = {
      file = ./ens-mail-pw.age;
    };

    programs.msmtp.enable = true;

    programs.notmuch = {
      enable = lib.mkDefault true;
      new.tags = [ "new" ];
    };

    accounts.email = {
      accounts.work = {
        notmuch.enable = true;
        folders.inbox = "INBOX";
        address = "julien@malka.sh";
        imap.host = "mail.luj.fr";
        msmtp.enable = true;
        primary = true;
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

  };
}
