{
  pkgs,
  config,
  ...
}:
{

  services.uptime-kuma = {
    enable = true;
    package = pkgs.uptime-kuma-beta;
    settings = {
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  services.nginx.virtualHosts."status.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
      proxyWebsockets = true;
    };
  };

  age.secrets."stateless-uptime-kuma-password".file = ../../secrets/stateless-uptime-kuma-password.age;
  statelessUptimeKuma = {
    enableService = true;
    probesConfig = {
      monitors = {
        "mdr" = {
          url = "https://82.67.34.230";
          keyword = "Ulm";
          type = "keyword";
          accepted_statuscodes = [ "200-299" ];
          headers = ''
            {
              "Host": "julienmalka.me"
            }
          '';
        };
      };
    };

    extraFlags = [
      "-s"
      "-v DEBUG"
    ];

    host = "http://localhost:${builtins.toString 3001}/";
    username = "Julien";
    passwordFile = config.age.secrets."stateless-uptime-kuma-password".path;
  };

}
