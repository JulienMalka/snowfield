{ pkgs, config, ... }:

{

  environment.systemPackages = [ config.services.nextcloud.occ ];

  age.secrets."nextcloud-admin-password" = {
    file = ../../private/secrets/nextcloud-admin-password.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  age.secrets."nextcloud-s3-token" = {
    file = ../../private/secrets/nextcloud-s3-token.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    configureRedis = true;
    database.createLocally = true;
    package = pkgs.nextcloud31;
    https = true;
    hostName = "nuage.luj.fr";
    autoUpdateApps.enable = true;

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.age.secrets."nextcloud-admin-password".path;
      objectstore.s3 = {
        enable = true;
        hostname = "s3.luj.fr";
        usePathStyle = true;
        port = 443;
        region = "paris";
        bucket = "nextcloud-bucket";
        key = "GK5e980f5f3c7e2780b931ccd0";
        secretFile = config.age.secrets."nextcloud-s3-token".path;
        verify_bucket_exists = false;
      };

    };

    settings = {
      overwriteprotocol = "https";
      overwritehost = "nuage.luj.fr";
      "overwrite.cli.url" = "https://nuage.luj.fr";
      updatechecker = false;
      default_phone_region = "FR";
      "memories.exiftool" = "${pkgs.exiftool}/bin/exiftool";
      "memories.vod.ffmpeg" = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      trusted_proxies = [ "::1" ];
      allow_local_remote_servers = true;
      allow_user_to_change_display_name = false;
      lost_password_link = "disabled";

    };

    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "32";
      "pm.start_servers" = "8";
      "pm.min_spare_servers" = "2";
      "pm.max_spare_servers" = "16";
      "pm.max_requests" = "500";
    };

    phpOptions = {
      "opcache.enable_cli" = "1";
      "opcache.interned_strings_buffer" = "32";
      "opcache.max_accelerated_files" = "10000";
      "opcache.memory_consumption" = "256";
      "opcache.revalidate_freq" = "1";
      "opcache.fast_shutdown" = "0";
      "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
    };

  };

  services.nginx.virtualHosts."nuage.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      proxy_max_temp_file_size 4096m;
    '';
  };

}
