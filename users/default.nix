{ config, pkgs, lib, ... }: {

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  sops.secrets.user-root-password.neededForUsers = true;

  programs.zsh.enable = true;

  users.users.root = {
    uid = config.ids.uids.root;
    description = "System administrator";
    home = "/root";
    shell = lib.mkForce config.users.defaultUserShell;
    group = "root";
    hashedPasswordFile = config.sops.secrets.user-root-password.path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower" ];
  };


}
