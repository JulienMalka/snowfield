{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.filerun;
  mysql_root_pw = [ (builtins.readFile /run/secrets/filerun-root-passwd) ];
  mysql_pw = [ (builtins.readFile /run/secrets/filerun-passwd) ];
  port = 2000;
in
{
  options.luj.filerun = {
    enable = mkEnableOption "enable filerun service";
    subdomain = mkOption {
      type = types.str;
    };
  };


  config = mkIf cfg.enable (recursiveUpdate {


    sops.secrets.filerun = {};

    
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers."filerun-mariadb" = {
      image = "mariadb:10.1";
      environment = {
        "MYSQL_USER" = "filerun";
        "MYSQL_DATABASE" = "filerundb";
        "TZ" = "Europe/Paris";
      };
      environmentFiles = [
        /run/secrets/filerun
      ];
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

    

  
    users.users.filerun = {
      isSystemUser = true;
      uid = 250;
      name = "filerun";
    };
    users.groups.filerun = {
      gid = 350;
      name = "filerun";
    };
    users.users.filerun.group = config.users.groups.filerun.name;

    virtualisation.oci-containers.containers."filerun" = {
      image = "filerun/filerun";
      environment = {
        "FR_DB_HOST" = "filerun-mariadb";
        "FR_DB_PORT" = "3306";
        "FR_DB_NAME" = "filerundb";
        "FR_DB_USER" = "filerun";
        "APACHE_RUN_USER" = config.users.users.filerun.name;
        "APACHE_RUN_USER_ID" = "250";
        "APACHE_RUN_GROUP" = config.users.groups.filerun.name;
        "APACHE_RUN_GROUP_ID" = "350"; 
      };
      environmentFiles = [
        /run/secrets/filerun
      ];
      ports = [ "2000:80" ];
      volumes = [
        "/home/delegator/filerun/web:/var/www/html"
        "/home/julien/cloud:/user-files"
      ];
      extraOptions = [ "--network=filerun-br" ];
    };

  } (mkSubdomain cfg.subdomain port));

}
