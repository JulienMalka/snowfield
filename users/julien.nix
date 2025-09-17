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
    openssh.authorizedPrincipals = [ "julien" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwMV/IsMl07Oa3Vw8hO4K4YLusREtNhZrYD/81/Bhqr julien@gallifrey"

      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADCpuBL/kSZShtXD6p/Nq9ok4w1DnlSoxToYgdOvUqo julien@telecom"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHH2mPgov6t7oFfEjtZr/DdJW5qSQYqbw+4uYitOCf9n julien@arcadia"
    ];
  };

  nix.settings.allowed-users = [ "julien" ];
  nix.settings.trusted-users = [ "julien" ];

  age.secrets.julien-password.file = ../private/secrets/user-julien-password.age;
}
