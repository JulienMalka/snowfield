{ pkgs, ... }:
{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.afew.enable = true;
  accounts.email = { 
    accounts.ens = {
    address = "julien.malka@ens.fr";
    imap.host = "clipper.ens.fr";
    mbsync = {
      enable = true;
      create = "maildir";
      };
    msmtp.enable = true;
    notmuch.enable = true;
    primary = true;
    realName = "Julien Malka";
    passwordCommand = "passwordCommand";
    smtp = {
      host = "clipper.ens.fr";
      };
    userName = "jmalka";
    };
};

services.mbsync.enable = true;
services.mbsync.frequency = "*-*-* *:*:00";
services.mbsync.postExec = "${pkgs.notmuch}/bin/notmuch new";
services.mbsync.verbose = false;

programs.notmuch = {
enable = true;
new.tags = ["new"];
hooks.postNew = ''
${pkgs.afew}/bin/afew --tag --new
${pkgs.afew}/bin/afew --move-mails
'';
};

}
