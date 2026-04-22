{
  luj.nginx.enable = true;
  services.nginx.virtualHosts."julienmalka.me" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      return 301 https://luj.fr$request_uri;
    '';
  };
}
