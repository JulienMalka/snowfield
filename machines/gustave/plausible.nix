{ config, ... }:

{
  services.plausible = {
    enable = true;
    adminUser = {
      activate = true;
      email = "analytics@luj.fr";
      passwordFile = config.age.secrets.plausible-admin-password.path;
    };
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
    plausible-admin-password.file = ../../secrets/plausible-password.age;
    plausible-secret-key-base.file = ../../secrets/plausible-keybase-secret.age;
  };
}
