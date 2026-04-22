{
  config,
  pkgs,
  ...
}:

let
  hostName = "meet.luj.fr";
  port = 3100;
  # Next.js inlines NEXT_PUBLIC_WEBAPP_URL into the build output, so the
  # deployment URL has to be baked into the package itself.
  package = pkgs.cal-diy.override { webappUrl = "https://${hostName}"; };
in
{

  age.secrets.cal-diy-env = {
    file = ./cal-diy-env.age;
    owner = "caldiy";
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "caldiy" ];
    ensureUsers = [
      {
        name = "caldiy";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.caldiy = {
    isSystemUser = true;
    group = "caldiy";
  };
  users.groups.caldiy = { };

  systemd.services.cal-diy = {
    description = "cal.diy scheduling platform";
    after = [
      "network.target"
      "postgresql.service"
    ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      NODE_ENV = "production";
      PORT = toString port;
      HOSTNAME = "127.0.0.1";
      DATABASE_URL = "postgresql://caldiy@localhost/caldiy?host=/run/postgresql";
      DATABASE_DIRECT_URL = "postgresql://caldiy@localhost/caldiy?host=/run/postgresql";
      NEXTAUTH_URL = "https://${hostName}";
      NEXT_PUBLIC_WEBAPP_URL = "https://${hostName}";
      NEXT_PUBLIC_WEBSITE_URL = "https://${hostName}";
    };

    serviceConfig = {
      User = "caldiy";
      Group = "caldiy";
      StateDirectory = "cal-diy";
      WorkingDirectory = "/var/lib/cal-diy";
      EnvironmentFile = config.age.secrets.cal-diy-env.path;
      ExecStartPre = "${package}/bin/cal-diy-migrate";
      ExecStart = "${package}/bin/cal-diy";
      Restart = "always";
      RestartSec = 10;
    };
  };

  services.nginx.virtualHosts.${hostName} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };

    # Anonymous visitors land on the /luj booking page; authenticated users
    # (those carrying a next-auth session cookie) get the full app.
    locations."= /".extraConfig = ''
      if ($http_cookie !~ "next-auth\.session-token") {
        return 302 /luj$is_args$args;
      }
      proxy_pass http://127.0.0.1:${toString port};
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
