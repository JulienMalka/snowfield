{ config, ... }:
{

  age.secrets."readeck-config".file = ../../secrets/readeck-config.age;

  services.nginx.virtualHosts."read.luj" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8000";
    };
  };

  services.readeck = {
    enable = true;
    environmentFile = config.age.secrets."readeck-config".path;
  };
}
