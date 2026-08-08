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
      ASSETS_BUCKET = "luj-org-notes";
      ASSETS_PREFIX = "assets";
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

  services.nginx.recommendedBrotliSettings = true;

  services.nginx.virtualHosts."luj.fr" = {
    enableACME = true;
    forceSSL = true;
    # HSTS: everything under luj.fr is already HTTPS-only (forceSSL on
    # every vhost), so committing browsers to HTTPS is safe. No `preload`
    # — that is an irreversible submission to the browser preload list.
    extraConfig = ''
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };

  # Canonical host is the apex; redirect www so the two never split link
  # equity or serve duplicate content. DNS for this subdomain is derived
  # automatically from the vhost declaration (same as the other
  # *.luj.fr vhosts on this machine).
  services.nginx.virtualHosts."www.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    # NB: not `globalRedirect` — the luj.nginx module (modules/nginx)
    # unconditionally materialises an (empty) `locations."/"` on every
    # vhost, and `globalRedirect` renders its own separate `location /`,
    # producing a duplicate `location "/"` that nginx rejects. Expressing
    # the redirect as a location merges into that single `/` block.
    locations."/".return = "301 https://luj.fr$request_uri";
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
