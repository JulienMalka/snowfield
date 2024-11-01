{ config, ... }:
{
  deployment.tags = [ "server" ];

  # Enable arkheon
  age.secrets."arkheon-token".file = ../secrets/arkheon-token.age;
  services.arkheon.record = {
    enable = true;

    tokenFile = config.age.secrets."arkheon-token".path;

    url = "https://arkheon.luj.fr";
  };

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
