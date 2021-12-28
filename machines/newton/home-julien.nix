{ pkgs, config, lib, ... }:
{

  sops.secrets.ssh-newton-pub = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
    mode = "0644";
    format = "binary";
    sopsFile = ../../secrets/ssh-newton-pub;
  };

  sops.secrets.ssh-newton-priv = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
    mode = "0600";
    format = "binary";
    sopsFile = ../../secrets/ssh-newton-priv;
  };



  luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.programs.git.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.emails = {
      enable = true;
      backend.enable = true;
    };
  };
}
