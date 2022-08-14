{ config, pkgs, lib, ... }:
let
  cfg = config.services.polr;
  attrToListEnv = attr: lib.mapAttrsToList (name: value: if value != null then (attrNameToPolrName name) + "=" + value else "") attr;
  listToEnvText = list: lib.foldr (a: b: a + "\n" + b) "" list;
  attrNameToPolrName = name: "APP_" + lib.toUpper name;
  neededConfig = ''
    POLR_SECRET_BYTES=2
    CACHE_DRIVER=file
    SESSION_DRIVER=file
    QUEUE_DRIVER=file
    VERSION=2.3.0
    VERSION_RELMONTH=Jan
    VERSION_RELDAY=28
    VERSION_RELYEAR=2020
    _API_KEY_LENGTH=15
    _ANALYTICS_MAX_DAYS_DIFF=365
    _PSEUDO_RANDOM_KEY_LENGTH=5
  '';

  renamedConfig = ''
    POLR_BASE=${cfg.config.base}
    DB_CONNECTION=${cfg.database.dbtype}
    DB_DATABASE=${cfg.database.dbname}
    DB_HOST=${cfg.database.dbhost}
    DB_PASSWORD={DBPASSWORD}
    DB_PORT=${cfg.database.dbport}
    DB_USERNAME=${cfg.database.dbuser}
    APP_KEY={APPKEY}
  '';


  createEnvFile = listToEnvText (attrToListEnv (lib.filterAttrs (n: v: n != "base" && n != "appkeyFile") cfg.config)) + "\n" + "POLR_SETUP_RAN=true\n" + renamedConfig + "\n" + neededConfig + "\n" + cfg.extraConfig;

in
with lib;
{
  options.services.polr = {
    enable = mkEnableOption "Enable polr service";

    adminpassFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The full path to a file that contains the admin password. Admin password is binded to this file and not set by Polr.
      '';
    };

    enableHttps = mkOption {
      type = types.bool;
      default = true;
      description = "Enables ssl and acme in the nginx virtualhost";
    };

    database = {

      createLocally = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Create the database and database user locally.
        '';
      };

      dbtype = mkOption {
        type = types.enum [ "sqlite" "pgsql" "mysql" ];
        default = "mysql";
        description = "Database type.";
      };

      dbname = mkOption {
        type = types.nullOr types.str;
        default = "polr";
        description = "Database name.";
      };

      dbuser = mkOption {
        type = types.nullOr types.str;
        default = "polr";
        description = "Database user.";
      };

      dbpassFile = mkOption {
        type = types.nullOr types.str;
        description = ''
          The full path to a file that contains the database password.
        '';
      };

      dbhost = mkOption {
        type = types.nullOr types.str;
        default = "localhost";
        description = ''
          Database host.
        '';
      };

      dbport = mkOption {
        type = with types; nullOr (either int str);
        default = "3306";
        description = "Database port.";
      };

    };

    config.name = mkOption {
      type = types.str;
      default = "Polr";
      description = "Name of the app, displayed in the page title and on the main page";
    };

    config.protocol = mkOption {
      type = types.str;
      default = "https://";
      description = "This is going to be at the beginning of all generated links";
    };

    config.address = mkOption {
      type = types.str;
      description = "Address of the application";
    };

    config.appkeyFile = mkOption {
      type = types.nullOr types.str;
      description = ''
        The full path to a file that contains the app key, a 32-character key.
      '';

    };


    config.env = mkOption {
      type = types.str;
      default = "production";
      description = "local/production";
    };

    config.debug = mkOption {
      type = types.str;
      default = "false";
      description = "Enable or disable debug printed on the page";
    };

    config.locale = mkOption {
      type = types.str;
      default = "en";
    };

    config.base = mkOption {
      type = types.str;
      default = "32";
      description = "Set to 32 or 62. Do not touch after initial configuration";
    };


    extraConfig = mkOption {
      type = with types; nullOr lines;
      default = '''';
    };
  };

  config = mkIf cfg.enable (mkMerge [

    {

      services.phpfpm.pools."polr" = {
        user = "polr";
        settings = {
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 100;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
          "php_admin_value[error_log]" = "stderr";
          "php_admin_flag[log_errors]" = true;
          "catch_workers_output" = true;
        };
        phpEnv."PATH" = lib.makeBinPath [ pkgs.php74 ];
        phpPackage = pkgs.php74;
      };


      services.nginx = {
        enable = true;
        virtualHosts.${cfg.config.address} = {
          root = "${pkgs.polr}/public";
          enableACME = cfg.enableHttps;
          forceSSL = cfg.enableHttps;
          locations."/".extraConfig = ''
            try_files $uri $uri/ /index.php$is_args$args;
            index index.php;
          '';

          locations."~ \.php$".extraConfig = ''
              try_files $uri = 404;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_index   index.php;
            fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass unix:${config.services.phpfpm.pools."polr".socket};
          '';
        };
      };

      users.users."polr" = {
        isSystemUser = true;
        group = "polr";
      };

      users.groups."polr" = { };


      systemd.services.polr-config = {
        wantedBy = [ "phpfpm-polr.service" ];
        wants = [ "polr-mysql.service" ];
        requiredBy = [ "phpfpm-polr.service" ];
        before = [ "phpfpm-polr.service" ];
        restartTriggers = [
          (builtins.hashFile "sha256" cfg.adminpassFile)
          (builtins.hashFile "sha256" cfg.database.dbpassFile)
          (builtins.hashFile "sha256" cfg.config.appkeyFile)
        ];
        serviceConfig = {
          User = "polr";
          Group = "polr";
          StateDirectory = "polr";
          RuntimeDirectory = "polr";
          LoadCredential = [ "dbpw:${cfg.database.dbpassFile}" "adminpw:${cfg.adminpassFile}" "appkey:${cfg.config.appkeyFile}" ];
          Type = "oneshot";
          RemainAfterExit = true;
          BindPaths = [ "/var/lib/polr/:${pkgs.polr}/storage/" ];
          BindReadOnlyPaths = [ "/var/lib/polr/.env:${pkgs.polr}/.env" ];
          ProtectHome = true;
          ProtectSystem = "strict";
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          PrivateMounts = true;
          PrivateNetwork = true;
          UMask = "0027";
        };
        script = ''
          ${pkgs.rsync}/bin/rsync ${builtins.toFile "env" createEnvFile}  /var/lib/polr/.env 
          mkdir -p /var/lib/polr/app
          mkdir -p /var/lib/polr/logs
          mkdir -p /var/lib/polr/framework
          mkdir -p /var/lib/polr/framework/sessions
          mkdir -p /var/lib/polr/framework/views
          mkdir -p /var/lib/polr/framework/cache
          DBPW="$(<"$CREDENTIALS_DIRECTORY/dbpw")";
          DBPW_ESC=$(printf '%s\n' "$DBPW" | sed -e 's/[\/&]/\\&/g')
          ADMINPW="$(<"$CREDENTIALS_DIRECTORY/adminpw")";
          APPKEY="$(<"$CREDENTIALS_DIRECTORY/appkey")";
          APPKEY_ESC=$(printf '%s\n' "$APPKEY" | sed -e 's/[\/&]/\\&/g')
          sed -i "s/{DBPASSWORD}/$DBPW_ESC/g" /var/lib/polr/.env
          sed -i "s/{APPKEY}/$APPKEY_ESC/g" /var/lib/polr/.env
          ${pkgs.php74}/bin/php ${pkgs.polr}/artisan migrate --force
          ${pkgs.php74}/bin/php ${pkgs.polr}/artisan init:createsuperuser $ADMINPW
        '';
      };

      systemd.services.phpfpm-polr.serviceConfig.BindPaths = [ "/var/lib/polr/:${pkgs.polr}/storage/" ];
      systemd.services.phpfpm-polr.serviceConfig.BindReadOnlyPaths = [ "/var/lib/polr/.env:${pkgs.polr}/.env" ];


    }

    (lib.mkIf cfg.database.createLocally {

      services.mysql = {
        enable = true;
        package = lib.mkDefault pkgs.mariadb;
      };


      systemd.services.polr-mysql = {
        after = [ "mysql.service" ];
        before = [ "polr-config.service" ];
        bindsTo = [ "mysql.service" ];
        wantedBy = [ "polr-config.target" ];
        path = [ pkgs.mariadb ];
        serviceConfig = {
          LoadCredential = [ "dbpw:${cfg.database.dbpassFile}" ];
          User = "mysql";
          ProtectHome = true;
          ProtectSystem = "strict";
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          PrivateMounts = true;
          PrivateNetwork = true;
          UMask = "0027";

        };
        script = '' 
          DBPW="$(<"$CREDENTIALS_DIRECTORY/dbpw")";
          ${pkgs.mariadb}/bin/mysql -u mysql -N << END 

          DROP USER IF EXISTS '${cfg.database.dbname}'@'localhost';
          CREATE USER '${cfg.database.dbname}'@'localhost' IDENTIFIED BY '$DBPW'; 
          CREATE DATABASE IF NOT EXISTS ${cfg.database.dbname};
          GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER,
          	CREATE TEMPORARY TABLES ON ${cfg.database.dbname}.* TO '${cfg.database.dbuser}'@'localhost'
          	IDENTIFIED BY '$DBPW';
          FLUSH privileges;
          END
          	  '';
      };

    })


    {
      assertions = [
        {
          assertion = cfg.database.createLocally -> cfg.database.dbtype == "mysql";
          message = ''services.polr.database.dbtype must be set to mysql if services.polr.database.createLocally is set to true.'';
        }
      ];
    }

  ]);

}


