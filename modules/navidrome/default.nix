{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.navidrome;
  port = 4533;
  settingsFormat = pkgs.formats.json {};
in
{

  options.luj.navidrome = {

    enable = mkEnableOption "activate navidrome service";

    user = mkOption {
      type = types.str;
      default = "navidrome";
      description = "User account under which Navidrome runs.";
    };

    group = mkOption {
      type = types.str;
      default = "navidrome";
      description = "Group under which Navidrome runs.";
    };


    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{

  sops.secrets."navidrome.json" = {
        owner = cfg.user;
        format = "binary";
        sopsFile = ../../secrets/navidrome-config;
      };



      systemd.services.navidrome = {
        
        description = "Navidrome Media Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = ''
            ${pkgs.navidrome}/bin/navidrome --configfile /run/secrets/navidrome.json
          '';
          StateDirectory = "navidrome";
          WorkingDirectory = "/var/lib/navidrome";
        };
      };



    }


    
      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))
      
      (mkIf cfg.nginx.enable (mkVPNSubdomain cfg.nginx.subdomain port))]);
      
 
}
