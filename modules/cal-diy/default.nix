{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.luj.cal-diy;
  port = 3100;
in
{
  options.luj.cal-diy = {
    enable = mkEnableOption "cal.diy scheduling platform";

    hostName = mkOption {
      type = types.str;
      example = "meet.example.com";
      description = "Public hostname the app is served at.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cal-diy.override {
        webappUrl = "https://${cfg.hostName}";
      };
      defaultText = literalExpression ''
        pkgs.cal-diy.override { webappUrl = "https://''${cfg.hostName}"; }
      '';
      description = ''
        The cal-diy package. Defaults to an override of `pkgs.cal-diy`
        with `webappUrl` set from `hostName`, since Next.js inlines
        `NEXT_PUBLIC_WEBAPP_URL` into the build output.
      '';
    };

    environmentFile = mkOption {
      type = types.path;
      description = ''
        Path to a file with runtime secrets (NEXTAUTH_SECRET,
        CALENDSO_ENCRYPTION_KEY, CRON_API_KEY, EMAIL_SERVER_*). Loaded
        via systemd EnvironmentFile.
      '';
    };
  };

  config = mkIf cfg.enable {
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
        NEXTAUTH_URL = "https://${cfg.hostName}";
        NEXT_PUBLIC_WEBAPP_URL = "https://${cfg.hostName}";
        NEXT_PUBLIC_WEBSITE_URL = "https://${cfg.hostName}";
      };

      serviceConfig = {
        User = "caldiy";
        Group = "caldiy";
        StateDirectory = "cal-diy";
        WorkingDirectory = "/var/lib/cal-diy";
        EnvironmentFile = cfg.environmentFile;
        ExecStartPre = "${cfg.package}/bin/cal-diy-migrate";
        ExecStart = "${cfg.package}/bin/cal-diy";
        Restart = "always";
        RestartSec = 10;
      };
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
