{ config, ... }:

{
  services.plausible = {
    enable = true;
    server = {
      baseUrl = "https://probable.luj.fr";
      port = 8455;
      secretKeybaseFile = config.age.secrets.plausible-secret-key-base.path;
    };
  };

  services.nginx.virtualHosts = {
    "probable.luj.fr" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.plausible.server.port}";
      };
    };
  };

  age.secrets = {
    plausible-admin-password.file = ../../private/secrets/plausible-password.age;
    plausible-secret-key-base.file = ../../private/secrets/plausible-keybase-secret.age;
  };
}
