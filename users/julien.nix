{ config, pkgs, lib, ... }: {

  users.users.julien = {
    isNormalUser = true;
    home = "/home/julien";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/JulienMalka.keys";
        sha256 = "sha256:0lhvhdrzp2vphqhkcgl34xzn0sill6w7mgq8xh1akm1z1rsvd9v4";
      })
    ];
  };

  nix.allowedUsers = [ "julien" ];
}
