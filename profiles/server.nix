{ config, ... }:
{
  deployment.tags = [ "server" ];

  # Enable arkheon
  age.secrets."arkheon-token".file = ../secrets/arkheon-token.age;
  services.arkheon.record = {
    enable = true;

    tokenFile = config.age.secrets."arkheon-token".path;

    url = "https://arkheon.luj.fr";
  };

}
