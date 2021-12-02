{ config, pkgs, ... }:
{

services.jellyfin = {
   enable = true;
   group = "tv";
   package = pkgs.jellyfin;
};

services.sonarr = {
   enable = true;
   openFirewall = true;
   group = "tv";
};

services.radarr = {
   enable = true;
   openFirewall = true;
   group = "tv";
};

services.transmission = {
   enable = true;
   group = "tv";
   downloadDirPermissions = "774";
   settings = {
      rpc-port = 9091;
      download-dir = "/home/transmission/Downloads/";
      incomplete-dir = "/home/transmission/Incomplete/";
      incomplete-dir-enable = true;
   };
};

services.jackett = {
   enable = true;
   openFirewall = true;
};


services.nginx = {
   enable = true;

   virtualHosts."julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/julienmalka.me";
      default = true;
   };

   virtualHosts."www.julienmalka.me" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/julienmalka.me";
   };

   virtualHosts."tv.julienmalka.me" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
         proxyPass = "http://localhost:8096";
      };
   };

   virtualHosts."series.julienmalka.me" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
         proxyPass = "http://localhost:8989";
      };
   };

   virtualHosts."downloads.julienmalka.me" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
         proxyPass = "http://localhost:9091";
      };
   };

   virtualHosts."jackett.julienmalka.me" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
         proxyPass = "http://localhost:9117";
      };
   };

virtualHosts."films.julienmalka.me" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:7878";
      };
    };




};






security.acme.certs = {
"www.julienmalka.me".email = "julien.malka@me.com";
 "julienmalka.me".email = "julien.malka@me.com";
 "tv.julienmalka.me".email = "julien.malka@me.com";
 "series.julienmalka.me".email = "julien.malka@me.com";
 "downloads.julienmalka.me".email = "julien.malka@me.com";
 "jackett.julienmalka.me".email = "julien.malka@me.com";
 "films.julienmalka.me".email = "julien.malka@me.com";
};

security.acme.acceptTerms = true;




}
