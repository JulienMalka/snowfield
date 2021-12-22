{ config, pkgs, lib, ... }: {


  users.mutableUsers = false;
  users.defaultUserShell = pkgs.fish;
  sops.secrets.user-root-password.neededForUsers = true;

  programs.fish.enable = true;

users.users.root = {
        uid = config.ids.uids.root;
        description = "System administrator";
        home = "/root";
        shell = lib.mkForce config.users.defaultUserShell;
        group = "root";
        passwordFile = config.sops.secrets.user-root-password.path;
      };


}
