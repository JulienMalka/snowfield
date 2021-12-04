{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.filerun;
in
{
  options.luj.filerun = {
    enable = mkEnableOption "enable filerun service";
  };


  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers."filerun-mariadb" = {
      image = "mariadb:10.1";
      environment = {
        "MYSQL_ROOT_PASSWORD" = "randompasswd";
        "MYSQL_USER" = "filerun";
        "MYSQL_PASSWORD" = "randompasswd";
        "MYSQL_DATABASE" = "filerundb";
        "TZ" = "Europe/Paris";
      };
      volumes = [ "/home/delegator/filerun/db:/var/lib/mysql" ];
      extraOptions = [ "--network=filerun-br" ];
    };

    systemd.services.init-filerun-network-and-files = {
      description = "Create the network bridge filerun-br for filerun.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in
        ''
          # Put a true at the end to prevent getting non-zero return code, which will
          # crash the whole service.
          check=$(${dockercli} network ls | grep "filerun-br" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create filerun-br
          else
            echo "filerun-br already exists in docker"
          fi
        '';
    };



    virtualisation.oci-containers.containers."filerun" = {
      image = "afian/filerun:libreoffice";
      environment = {
        "FR_DB_HOST" = "filerun-mariadb"; # !! IMPORTANT
        "FR_DB_PORT" = "3306";
        "FR_DB_NAME" = "filerundb";
        "FR_DB_USER" = "filerun";
        "FR_DB_PASS" = "randompasswd";
        "APACHE_RUN_USER" = "filerunuser";
        "APACHE_RUN_USER_ID" = "1000";
        "APACHE_RUN_GROUP" = "hello";
        "APACHE_RUN_GROUP_ID" = "100";
      };
      ports = [ "2000:80" ];
      volumes = [
        "/home/delegator/filerun/web:/var/www/html"
        "/home/julien/cloud:/user-files"
      ];
      extraOptions = [ "--network=filerun-br" ];
    };


    luj.nginx.enable = true;
    virtualHosts."cloud.julienmalka.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:2000";
        extraConfig = ''
          proxy_set_header  X-Forwarded-Proto https;
          proxy_set_header    X-Forwarded-Port 443;
        '';
      };



    };



  }
