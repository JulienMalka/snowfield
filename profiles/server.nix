{
  deployment.tags = [ "server" ];

  # Nice motd
  programs.rust-motd = {
    enable = true;
    order = [
      "filesystems"
      "memory"
      "last_login"
      "uptime"
    ];
    settings = {
      uptime.prefix = "Up";
      filesystems.root = "/";
      memory.swap_pos = "below";
      last_login.root = 3;
      last_login.julien = 3;
    };
  };

}
