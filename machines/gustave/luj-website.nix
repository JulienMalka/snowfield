{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.luj-website ];
  age.secrets."luj-website-s3" = {
    file = ./luj-website-s3.age;
  };

  age.secrets."luj-website-auth" = {
    file = ./luj-website-auth.age;
  };

  systemd.services.luj-website = {
    description = "luj-website";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      LEPTOS_SITE_ADDR = "127.0.0.1:3001";
      LEPTOS_SITE_ROOT = "${pkgs.luj-website}/share/luj-website/site";
      S3_BUCKET = "luj-org-notes";
      AWS_ENDPOINT_URL = "https://s3.luj.fr";
      AWS_REGION = "paris";
    };

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      ExecStart = "${pkgs.luj-website}/bin/luj-website";
      StateDirectory = "luj-website";
      WorkingDirectory = "/var/lib/luj-website";
      Restart = "on-failure";
      RestartSec = "5s";

      EnvironmentFile = config.age.secrets."luj-website-s3".path;
      LoadCredential = "auth.toml:${config.age.secrets."luj-website-auth".path}";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };

  services.nginx.virtualHosts."luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."iljuj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };
}
