{ config, pkgs, ... }:

let
  port = 5674;
  remote = "https://git.luj.fr";
in
{

  systemd.services.josh = {
    description = "josh - partial cloning of monorepos";
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.git
      pkgs.bash
    ];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "josh";
      Restart = "always";
      ExecStart = "${pkgs.josh}/bin/josh-proxy --no-background --local /var/lib/josh --port ${toString port} --remote ${remote} --require-auth";
    };
  };

  age.secrets."notes-phd-auth" = {
    file = ../biblios/notes-phd-auth.age;
    owner = "nginx";
  };

  age.secrets."nginx-git-token" = {
    file = ./secrets/nginx-git-token.age;
    owner = "nginx";
  };

  services.nginx.virtualHosts."code.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."~ ^/luj/notes\\.git:workspace=phd\\.git" = {
      basicAuthFile = config.age.secrets.notes-phd-auth.path;
      # Included file holds the upstream forge token and injects it as a basic
      # auth header on the proxy request.
      extraConfig = ''
        proxy_pass http://127.0.0.1:${toString port};
        include ${config.age.secrets.nginx-git-token.path};
      '';
    };
  };
}
