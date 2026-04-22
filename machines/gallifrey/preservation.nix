{
  luj.preservation.enable = true;

  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.julien = {
      directories = [
        ".zotero"
        ".cache/zotero"
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        ".config/cosmic"
        ".local/share/direnv"
        ".local/state/cosmic-comp"
        ".local/share/atuin"
        ".claude"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/pika-backup"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        ".cache/mu"
        "Maildir"
      ];
      files = [
        ".config/gnome-initial-setup-done"
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
        ".local/share/com.ranfdev.Notify.sqlite"
      ];
    };
  };
}
