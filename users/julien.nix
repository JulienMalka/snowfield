{ config, pkgs, lib, ... }: {


  sops.secrets.user-julien-password.neededForUsers = true;


  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    extraGroups = [ "wheel" "docker" config.users.groups.keys.name]; 
    shell = pkgs.fish;
    passwordFile = config.sops.secrets.user-julien-password.path;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256-27lY1/ZmItXNEB03ULu10TUbGvqwbB1EiVrytZONtak=";
      })
    ];
  };


  nix.allowedUsers = [ "julien" ];
}
