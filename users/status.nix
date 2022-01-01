{ config, pkgs, lib, ... }: {

  users.users.status = {
    isNormalUser = true;
    home = "/home/status";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-nBgn7jOqi/nPHhTy3x/oirL+A4X2gbmwy1NXLZhV99M=";
      })
    ];
  };

  nix.allowedUsers = [ "status" ];
} 
