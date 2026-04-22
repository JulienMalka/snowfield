{
  luj.preservation.enable = true;

  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.julien = {
      directories = [
        "dev"
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        ".local/share/direnv"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        "Maildir"
      ];
      files = [
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
      ];
    };
  };
}
