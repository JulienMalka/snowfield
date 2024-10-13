{
  config,
  pkgs,
  lib,
  ...
}:
{

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.fish;

  programs.fish.enable = true;

  age.secrets.user-root-password.file = ../secrets/user-root-password.age;

  users.users.root = {
    uid = config.ids.uids.root;
    description = "System administrator";
    home = "/root";
    shell = lib.mkForce config.users.defaultUserShell;
    group = "root";
    hashedPasswordFile = config.age.secrets.user-root-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAa0wll9ildhgPiV0DhgJXXtw3TQr5VkNxxxPspHSbX julien@gallifrey"
    ];
  };
}
