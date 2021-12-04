{ lib, pkgs, config, ... }:
with lib;
let 
  cfg = config.luj.radarr;
  port = 7878;
in {

  options.luj.radarr = { 
    enable = mkEnableOption "activate radarr service"; 
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{ 
    services.radarr = {
      enable = true;
      #user = "transmission";
      #group = "transmission";
      #dataDir = "/var/lib/sonarr/.config/NzbDrone";
      group = "tv";
    };
    networking.firewall = { allowedTCPPorts = [ port ]; };
  } 

    (mkIf cfg.nginx.enable {
      luj.nginx.enable = true;
      services.nginx.virtualHosts."${cfg.nginx.subdomain}.julienmalka.me" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
        };
      };

    })
  ]);
    


  
}
