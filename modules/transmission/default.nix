{ lib, pkgs, config, ... }:
with lib;
let 
  cfg = config.luj.transmission;
  port = 9091;
in {

  options.luj.transmission = { 
    enable = mkEnableOption "activate transmission service"; 
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{ 
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
    networking.firewall = { allowedTCPPorts = [ port ]; };
  } 

    (mkIf cfg.nginx.enable {
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
