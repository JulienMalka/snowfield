{ pkgs, config, lib, ... }:
let
  cfg = config.luj.emails;
in
with lib;
{
  options.luj.emails = {
    enable = mkEnableOption "enable mail management";
  };


  config = mkIf cfg.enable {
    home.packages = [ pkgs.notmuch-addrlookup ];
    programs.mbsync.enable = true;
    programs.neomutt.enable = true;
    programs.msmtp.enable = true;
    accounts.email = {
      accounts.ens = {
        notmuch.enable = true;
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
        notmuch.enable = true;
        address = "julien@malka.sh";
        imap.host = "mail.julienmalka.me";
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
          host = "mail.julienmalka.me";
        };
        userName = "julien@malka.sh";
      };

      accounts.telecom = {
        notmuch.enable = true;
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
        notmuch.enable = true;
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
    services.mbsync.postExec = "${pkgs.notmuch}/bin/notmuch new";
    programs.notmuch = {
      enable = true;
      new.tags = [ ];
      hooks.postNew = ''
        # julien@malka.sh
        notmuch tag +work-inbox -- folder:work/Inbox
        notmuch tag +work-lobsters -- folder:work/Inbox/lobsters
        notmuch tag +work-dn42  -- folder:work/Inbox/dn42
        notmuch tag +work-fosdem -- folder:work/Inbox/fosdem
        notmuch tag +work-frnog -- folder:work/Inbox/frnog
        notmuch tag +work-github -- folder:work/Inbox/github
        notmuch tag +work-netdata -- folder:work/Inbox/netdata
        notmuch tag +work-nixos-discourse -- folder:work/Inbox/nixos-discourse
        notmuch tag +work-proxmox -- folder:work/Inbox/proxmox

        #julien.malka@ens.fr
        notmuch tag +ens-inbox path:ens/Inbox/**
        notmuch tag +ens-bilan-carbone -ens-inbox -- path:ens/Bilan-Carbone/**
        notmuch tag +ens-dg -ens-inbox -- path:ens/DG/**
        notmuch tag +ens-cof -ens-inbox -- path:ens/COF/**
        notmuch tag +ens-fanfare -ens-inbox -- path:ens/Fanfare/**
        notmuch tag +ens-kfet -ens-inbox -- path:ens/K-Fet/**


        #julien.malka@telecom-paris.fr
        notmuch tag +telecom-inbox -- folder:telecom/Inbox
        notmuch tag +telecom-gdr-gpl -- folder:telecom/Inbox/gdr-gpl
        notmuch tag +telecom-gdr-sec -- folder:telecom/Inbox/gdr-sec
        notmuch tag +telecom-infres-tous -- folder:telecom/Inbox/infres-tous
        notmuch tag +telecom-tous -- folder:telecom/Inbox/telecom-tous

        #luj@dgnum.eu
        notmuch tag +dgnum-inbox path:dgnum/Inbox/**
        notmuch tag +dgnum-bureau -dgnum-inbox -- path:dgnum/Inbox/Bureau/**
        notmuch tag +dgnum-nixcon -dgnum-inbox -- path:dgnum/Inbox/NixCon/**

        ${pkgs.notifymuch}/bin/notifymuch

      '';
    };

    xdg.configFile = {
      "neomutt/neomuttrc".source = lib.mkForce ./neomuttrc;
      "neomutt/dracula.muttrc".source = lib.mkForce ./dracula.muttrc;
      "neomutt/ens.profile".source = lib.mkForce ./ens.profile;
      "neomutt/telecom.profile".source = lib.mkForce ./telecom.profile;
      "neomutt/work.profile".source = lib.mkForce ./work.profile;
      "neomutt/discourse.profile".source = lib.mkForce ./discourse.profile;
      "neomutt/dgnum.profile".source = lib.mkForce ./dgnum.profile;
      "notifymuch/notifymuch.cfg".source = lib.mkForce ./notifymuch;
    };


  };
}


