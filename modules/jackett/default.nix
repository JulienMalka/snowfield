{ lib, pkgs, config, ... }:
with lib;
let 
  cfg = config.luj.jackett;
  port = 9117;
in {

  options.luj.jackett = { 
    enable = mkEnableOption "activate jackett service"; 
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{ 
    services.jackett = {
      enable = true;
    };
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
