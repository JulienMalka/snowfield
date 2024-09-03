{ pkgs, ... }:
{
  users.users.borg = {
    home = "/home/borg";
    group = "borg";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAziNbLEO9D69xUGPGEq3eXYauFuOlvhqQTwpLNKjFqs julien@tower"
    ];

  };
  users.groups.borg = { };

  environment.systemPackages = with pkgs; [ borgbackup ];

}
