{ config, pkgs, lib, ... }: {

  sops.secrets.user-julien-password.neededForUsers = true;

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" config.users.groups.keys.name]; 
    shell = pkgs.fish;
    passwordFile = config.sops.secrets.user-julien-password.path;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-nBgn7jOqi/nPHhTy3x/oirL+A4X2gbmwy1NXLZhV99M=";
      })
    ];
  };

  nix.allowedUsers = [ "julien" ];

}
