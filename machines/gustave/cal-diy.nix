{ config, ... }:
{
  age.secrets.cal-diy-env = {
    file = ./cal-diy-env.age;
    owner = "caldiy";
  };

  luj.cal-diy = {
    enable = true;
    hostName = "meet.luj.fr";
    environmentFile = config.age.secrets.cal-diy-env.path;
  };

  services.nginx.virtualHosts."meet.luj.fr".locations."= /" = {
    extraConfig = ''
      if ($http_cookie !~ "next-auth\.session-token") {
        return 302 /luj$is_args$args;
      }
      proxy_pass http://127.0.0.1:3100;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };
}
