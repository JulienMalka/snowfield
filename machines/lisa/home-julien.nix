_:
{

  sops.secrets.ssh-lisa-pub = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
    mode = "0644";
    format = "binary";
    sopsFile = ../../secrets/ssh-lisa-pub;
  };

  sops.secrets.ssh-lisa-priv = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
    mode = "0600";
    format = "binary";
    sopsFile = ../../secrets/ssh-lisa-priv;
  };



 luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
  };
}
