{ pkgs, config, lib, ... }:
let
  cfg = config.luj.emails;
in
with lib;
{
  options.luj.emails = {
    enable = mkEnableOption "enable mail management";
    backend.enable = mkEnableOption "enable filtering backend";
  };


  config = mkMerge [
    (mkIf cfg.enable {
      programs.mbsync.enable = true;
      programs.neomutt.enable = true;
      programs.msmtp.enable = true;
      accounts.email = {
        accounts.ens = {
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
          passwordCommand = "${pkgs.coreutils}/bin/cat /home/julien/.config/ens-mail-passwd";
          smtp = {
            host = "clipper.ens.fr";
          };
          userName = "jmalka";
        };
      };
      services.mbsync = {
        enable = true;
        frequency = "minutely";
        verbose = true;
      };
      xdg.configFile = {
        "neomutt/neomuttrc".source = lib.mkForce ./neomuttrc;
      };


    })

    (mkIf (cfg.enable && cfg.backend.enable) {
      programs.afew.enable = true;
      accounts.email.accounts.ens.notmuch.enable = true;
      services.mbsync.postExec = "${pkgs.notmuch}/bin/notmuch new";
      programs.notmuch = {
        enable = true;
        new.tags = [ "new" ];
        hooks.postNew = ''
          ${pkgs.afew}/bin/afew --tag --new
          ${pkgs.afew}/bin/afew --move-mails
        '';
      };
      xdg.configFile = {
        "afew/config".source = lib.mkForce ./afewconfig;
      };


    })


  ];

}
