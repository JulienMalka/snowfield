{ config, pkgs, lib, ... }: {

  users.users.status = {
    isNormalUser = true;
    home = "/home/status";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-/i6WOEWBfXnRln9r6GCznoc47UzN+jInkWjTSqNafHI=";
      })
    ];
  };

  nix.allowedUsers = [ "status" ];
} 
