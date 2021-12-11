{ config, pkgs, lib, ... }: {

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" ]; 
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256:d9IujbXim6tE3RYdwPwqRVMOEmRW/gbDkHlYn/QnG0w=";
      })
    ];
  };

  nix.allowedUsers = [ "julien" ];
}
