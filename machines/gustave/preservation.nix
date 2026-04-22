{
  luj.preservation = {
    enable = true;
    earlyBoot = true;
  };

  preservation.preserveAt."/persistent" = {
    directories = [
      {
        directory = "/srv";
        inInitrd = true;
      }
    ];
    # Host key cert comes from step-ca; keep it alongside the key pair.
    files = [
      "/etc/ssh/ssh_host_ed25519_key-cert.pub"
    ];
    users.julien = {
      directories = [
        ".ssh"
        ".local/share/direnv"
        ".gnupg"
        ".local/share/keyrings"
        "Maildir"
      ];
    };
  };
}
