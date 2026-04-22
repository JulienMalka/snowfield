{
  services.nginx.virtualHosts = {
    "staging-lila.luj.fr" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8004";
    };

    "slack-bot.luj.fr" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8005";
    };

    "git.luj.fr" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
    };
  };
}
