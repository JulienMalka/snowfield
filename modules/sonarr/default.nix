{ lib, pkgs, config, ... }:
with lib;
let 
  cfg = config.luj.sonarr;
  port = 8989;
in {

  options.luj.sonarr = { 
    enable = mkEnableOption "activate sonarr service"; 
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{ 
    services.sonarr = {
      enable = true;
      group = "tv";
    };
    users.groups.tv = { name = "tv"; };
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
