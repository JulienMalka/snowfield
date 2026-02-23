{ config, ... }:
{
  services.josh = {
    enable = true;
    remote = "https://git.luj.fr";
  };

  age.secrets."notes-phd-auth" = {
    file = ../biblios/notes-phd-auth.age;
    owner = "nginx";
  };

  age.secrets."nginx-git-token" = {
    file = ./secrets/nginx-git-token.age;
    owner = "nginx";
  };

  services.nginx.virtualHosts = {
    "code.luj.fr" = {
      forceSSL = true;
      enableACME = true;
      locations."~ ^/luj/notes\.git:workspace=phd\.git" = {
        basicAuthFile = config.age.secrets.notes-phd-auth.path;
        # Included file contains the token to connect to upstream forge
        # and sets it as a basic auth header
        extraConfig = ''
          proxy_pass http://127.0.0.1:5674;
          include ${config.age.secrets.nginx-git-token.path};
        '';
      };
    };
  };

}
