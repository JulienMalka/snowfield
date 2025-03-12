{ pkgs, ... }:
{
  luj.hmgr.julien = {

    luj.emails.enable = true;
    luj.programs.fish.enable = true;
    systemd.user.startServices = "sd-switch";

    home.persistence."/persistent/home/julien" = {
      directories = [
        ".ssh"
        ".local/share/direnv"
        ".gnupg"
        ".local/share/keyrings"
        "Maildir"
      ];
      allowOther = true;
    };

    home.stateVersion = "23.11";
    home.packages = [ pkgs.muchsync ];
  };
}
