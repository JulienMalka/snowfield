{ pkgs, lib, config, ... }:
{
  sops.secrets.ssh-macintosh-pub = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
    mode = "0644";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-pub;
  };

  sops.secrets.ssh-macintosh-priv = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
    mode = "0600";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-priv;
  };


  luj.hmgr.julien = {
    home.stateVersion = "22.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
  };
}
