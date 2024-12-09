{ config, pkgs, ... }:
{

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [
      "wheel"
      config.users.groups.keys.name
      "networkmanager"
      "davfs2"
      "adbusers"
      "audio"
      "pipewire"
      "dialout"
      "video"
      "docker"
    ];
    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.julien-password.path;
  };

  nix.settings.allowed-users = [ "julien" ];
  nix.settings.trusted-users = [ "julien" ];

  age.secrets.julien-password.file = ../secrets/user-julien-password.age;
}
