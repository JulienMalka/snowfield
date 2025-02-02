{ config, inputs, ... }:
let
  inherit (import inputs.unstable { }) readeck;
in
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
    package = readeck;
    environmentFile = config.age.secrets."readeck-config".path;
  };
}
