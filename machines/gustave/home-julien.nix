{ pkgs, ... }:
{
  luj.hmgr.julien = {

    home.persistence."/persistent/home/julien" = {
      files = [
        ".config/gnome-initial-setup-done"
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
        ".local/share/com.ranfdev.Notify.sqlite"
      ];
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        "devold"
        ".config/cosmic"
        ".local/share/direnv"
        ".local/state/cosmic-comp"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/pika-backup"
        ".config/Element"
        ".step"
        ".emacs.d"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        ".cache/mu"
        "Maildir"
      ];
      allowOther = true;
    };

    home.stateVersion = "23.11";
    home.packages = [ pkgs.hello ];
  };
}
