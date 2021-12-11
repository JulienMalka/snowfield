{ config, pkgs, lib, ... }: {

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" ]; 
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256:2NLoT1/N6Y1uZQ+KLGeRLBPNkc4z3jrYrN9A4bCJWkU=";
      })
    ];
  };

  nix.allowedUsers = [ "julien" ];
}
