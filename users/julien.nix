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
        sha256 = "sha256-jx0/AAAeq5d6h1ytdUUnF/bMcn4h0UIKQCwzi3S5+YQ=";
      })
    ];
  };


  nix.allowedUsers = [ "julien" ];
}
