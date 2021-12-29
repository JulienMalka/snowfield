{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.hydra;
  port = 9876;
in
{

  options.luj.hydra = {
    enable = mkEnableOption "activate hydra service";
    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{

      services.hydra = {
        enable = true;
        notificationSender = "hydra@localhost";
        port = port;
        buildMachinesFiles = [ ];
        useSubstitutes = true;
      };

      networking.firewall = { allowedTCPPorts = [ port ]; };
    }

      (mkIf cfg.nginx.enable (recursiveUpdate {
        services.hydra.hydraURL = "${cfg.nginx.subdomain}.julienmalka.me";
      } (mkSubdomain cfg.nginx.subdomain port)) )]);




}
