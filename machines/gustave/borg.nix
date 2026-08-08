# [[file:../../org/20260720T150500==public--how-my-backups-work__infra_backups.org::*The other end of the pipe][The other end of the pipe:1]]
{ pkgs, ... }:
{
  users.users.borg = {
    home = "/home/borg";
    group = "borg";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAziNbLEO9D69xUGPGEq3eXYauFuOlvhqQTwpLNKjFqs julien@tower"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAa0wll9ildhgPiV0DhgJXXtw3TQr5VkNxxxPspHSbX julien@gallifrey"
    ];

  };
  users.groups.borg = { };

  environment.systemPackages = with pkgs; [ borgbackup ];
  # The other end of the pipe:1 ends here

  # [[file:../../org/20260720T150500==public--how-my-backups-work__infra_backups.org::*The other end of the pipe][The other end of the pipe:2]]
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        {
          directory = "/home/borg";
          user = "borg";
          group = "users";
        }
      ];
    };
  };

}
# The other end of the pipe:2 ends here
