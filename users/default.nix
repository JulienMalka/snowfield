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

  age.secrets.user-root-password.file = ../private/secrets/user-root-password.age;

  users.users.root = {
    uid = config.ids.uids.root;
    description = "System administrator";
    home = "/root";
    shell = lib.mkForce config.users.defaultUserShell;
    group = "root";
    hashedPasswordFile = config.age.secrets.user-root-password.path;
    openssh.authorizedPrincipals = [ "julien" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwMV/IsMl07Oa3Vw8hO4K4YLusREtNhZrYD/81/Bhqr julien@gallifrey"
    ];
  };
}
