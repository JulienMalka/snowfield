{ config, pkgs, lib, ... }: {


  sops.secrets.user-julien-password.neededForUsers = true;


  users.groups.docker = {};
  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" "docker" config.users.groups.keys.name]; 
    shell = pkgs.fish;
    passwordFile = config.sops.secrets.user-julien-password.path;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256:2NLoT1/N6Y1uZQ+KLGeRLBPNkc4z3jrYrN9A4bCJWkU=";
      })
    ];
  };


  nix.allowedUsers = [ "julien" ];
}
