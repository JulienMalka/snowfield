{ config, pkgs, lib, ... }: {

  users.users.status = {
    isNormalUser = true;
    home = "/home/status";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-Ooh97vo6d4NR6xDhLpofWPYgImPFrwSWBOGxkZUWscQ=";
      })
    ];
  };

  nix.settings.allowed-users = [ "status" ];
} 
