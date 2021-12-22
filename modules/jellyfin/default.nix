{ lib, pkgs, config, ... }:
with lib;
let 
  cfg = config.luj.jellyfin;
  port = 8096;
in {

  options.luj.jellyfin = { 
    enable = mkEnableOption "activate jellyfin service"; 
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{ 
    services.jellyfin = {
      enable = true;
      group = "tv";
      package = pkgs.jellyfin; 
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
