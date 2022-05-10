{ config, pkgs, lib, ... }: {

  users.users.status = {
    isNormalUser = true;
    home = "/home/status";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-ZTQpJO5/z/RIzvNpLBHv2GyCn8cvWsN5Hx3pd6s7RYY=";
      })
    ];
  };

  nix.allowedUsers = [ "status" ];
} 
