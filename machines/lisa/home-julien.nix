_: {

  age.secrets.ssh-lisa-pub = {
    file = ../../secrets/ssh-lisa-pub.age;
    mode = "0644";
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
  };

  age.secrets.ssh-lisa-priv = {
    file = ../../secrets/ssh-lisa-priv.age;
    mode = "0600";
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
  };

  luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
  };
}
