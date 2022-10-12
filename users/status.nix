{ config, pkgs, lib, ... }: {

  users.users.status = {
    isNormalUser = true;
    home = "/home/status";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-1cbFnmpSt74KKcAthJswmBEFVR6cn9oVClK/Pu33OKQ=";
      })
    ];
  };

  nix.allowedUsers = [ "status" ];
} 
