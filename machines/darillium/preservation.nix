{
  luj.preservation.enable = true;

  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.julien = {
      directories = [
        ".ssh"
        ".mozilla"
        ".config/mozilla"
        ".local/share/mozilla"
        ".local/state/mozilla"
        ".cache/mozilla"
        ".gnupg"
        ".local/share/direnv"
        ".local/share/atuin"
        ".claude"
        ".config/Signal"
        ".config/dconf"
        ".local/share/keyrings"
        ".config/noctalia"
        ".cache/noctalia"
        ".cache/mu"
        ".step"
        ".zotero"
        ".cache/zotero"
        "Zotero"
        "Maildir"
        "Documents"
        "Pictures"
        "dev"
      ];
    };
  };
}
