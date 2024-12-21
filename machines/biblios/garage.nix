{
  config,
  pkgs,
  ...
}:
let
  api_domain = "s3.luj.fr";

in
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1_0_1;

    settings = {
      replication_factor = 1;
      db_engine = "lmdb";
      compression_level = 0;
      s3_api = {
        s3_region = "paris";
        api_bind_addr = "[::]:3900";
        root_domain = ".${api_domain}";
      };
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";

      admin.api_bind_addr = "127.0.0.1:3903";
    };

    environmentFile = config.age.secrets."garage-env-file".path;
  };

  age.secrets."garage-env-file".file = ../../secrets/garage-env-file.age;

  services.nginx.virtualHosts."${api_domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3900";
      extraConfig = ''
        proxy_max_temp_file_size 0;
        client_max_body_size 5G;
      '';
    };
  };
}
