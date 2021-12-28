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


    sops.secrets.transmission = {
      owner = "mediaserver";
      format = "binary";
      sopsFile = ../../secrets/transmission-login;
    };

    services.transmission = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      credentialsFile = "/run/secrets/transmission";
      downloadDirPermissions = "770";
      settings = {
        rpc-port = 9091;
        download-dir = "/home/mediaserver/downloads/complete/";
        incomplete-dir = "/home/mediaserver/downloads/incomplete/";
        incomplete-dir-enable = true;
      };
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
