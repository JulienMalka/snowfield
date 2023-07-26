{ config, pkgs, lib, ... }: {

  sops.secrets.user-julien-password.neededForUsers = true;

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" config.users.groups.keys.name "filerun" "networkmanager" "davfs2" "adbusers" ];
    shell = pkgs.fish;
    passwordFile = config.sops.secrets.user-julien-password.path;
  };


  nix.settings.allowed-users = [ "julien" ];
  nix.settings.trusted-users = [ "julien" ];

  sops.secrets.ens-mail-passwd = {
    owner = "julien";
    path = "/home/julien/.config/ens-mail-passwd";
  };

  sops.secrets.sendinblue-mail-passwd = { };
  sops.secrets.git-gpg-private-key = {
    owner = "julien";
    mode = "0440";
    group = config.users.groups.keys.name;
    sopsFile = ../secrets/git-gpg-private-key;
    format = "binary";
  };


}
