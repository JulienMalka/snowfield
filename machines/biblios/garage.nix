{
  config,
  pkgs,
  lib,
  ...
}:
let
  api_domain = "s3.luj.fr";

in
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1;

    settings = {
      replication_factor = 1;
      db_engine = "lmdb";
      compression_level = 0;
      s3_api = {
        s3_region = "paris";
        api_bind_addr = "[::]:3900";
        root_domain = ".${api_domain}";
      };
      s3_web = {
        bind_addr = "127.0.0.1:3902";
        root_domain = ".cdn.luj.fr";
        index = "index.html";
      };

      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";

      admin.api_bind_addr = "127.0.0.1:3903";
    };

    environmentFile = config.age.secrets."garage-env-file".path;
  };

  age.secrets."garage-env-file".file = ../../private/secrets/garage-env-file.age;
  age.secrets."book-auth" = {
    file = ../../private/secrets/book-auth.age;
    owner = "nginx";
  };
  age.secrets."notes-phd-auth" = {
    file = ../../private/secrets/notes-phd-auth.age;
    owner = "nginx";
  };
  age.secrets."notes-perso-auth" = {
    file = ../../private/secrets/notes-perso-auth.age;
    owner = "nginx";
  };

  services.nginx.virtualHosts."${api_domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3900";
      extraConfig = ''
        proxy_max_temp_file_size 0;
        proxy_request_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        client_max_body_size 5G;
      '';
    };
  };

  services.nginx.virtualHosts."cdn.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:3902;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
    '';
  };

  services.nginx.virtualHosts."hownix.works" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:3902;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
    '';
    locations."/book" = {
      basicAuthFile = config.age.secrets.book-auth.path;
      extraConfig = ''
        proxy_pass http://127.0.0.1:3902;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';

    };
  };

  services.nginx.virtualHosts."luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:3902;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
    '';
    locations."/notes" = {
      extraConfig = ''
        return 301 $scheme://$host/notes/;
      '';
    };

    # Main notes application
    locations."/notes/" = {
      extraConfig = ''
        proxy_pass http://100.100.45.24:3003;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };

    # JavaScript/WASM bundles
    locations."/pkg/" = {
      extraConfig = ''
        proxy_pass http://100.100.45.24:3003/pkg/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };

    # Static assets
    locations."/public/" = {
      extraConfig = ''
        proxy_pass http://100.100.45.24:3003/public/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };

    # Server function endpoints
    locations."/api/" = {
      extraConfig = ''
        proxy_pass http://100.100.45.24:3003/api/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };
  };

  services.nginx.virtualHosts."notes.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      basicAuthFile = config.age.secrets.notes-perso-auth.path;
      proxyPass = "http://127.0.0.1:3902";

      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };
  };

  services.nginx.virtualHosts."phd.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      basicAuthFile = config.age.secrets.notes-phd-auth.path;
      proxyPass = "http://127.0.0.1:3902";

      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
      '';
    };
  };

  machine.meta.zones."luj.fr".A = [
    config.machine.meta.ips.public.ipv4
  ];
  machine.meta.zones."luj.fr".AAAA = [
    config.machine.meta.ips.public.ipv6
  ];

  machine.meta.zones."hownix.works".A = lib.mkForce [
    "35.205.222.138"
  ];

  machine.meta.probes.monitors."s3.luj.fr - IPv4".accepted_statuscodes = [ "403" ];
  machine.meta.probes.monitors."s3.luj.fr - IPv6".accepted_statuscodes = [ "403" ];

  machine.meta.probes.monitors."cdn.luj.fr - IPv4".accepted_statuscodes = [ "404" ];
  machine.meta.probes.monitors."cdn.luj.fr - IPv6".accepted_statuscodes = [ "404" ];

  machine.meta.probes.monitors."notes.luj.fr - IPv4".accepted_statuscodes = [ "401" ];
  machine.meta.probes.monitors."notes.luj.fr - IPv6".accepted_statuscodes = [ "401" ];

  machine.meta.probes.monitors."phd.luj.fr - IPv4".accepted_statuscodes = [ "401" ];
  machine.meta.probes.monitors."phd.luj.fr - IPv6".accepted_statuscodes = [ "401" ];

  machine.meta.probes.monitors = {
    "luj.fr - IPv4" = {
      url = "https://${config.machine.meta.ips.public.ipv4}";
      type = "http";
      accepted_statuscodes = [ "200-299" ];
      notificationIDList = [ 1 ];
      headers = ''
        {
          "Host": "luj.fr"
        }
      '';
    };
    "luj.fr - IPv6" = {
      url = "https://[${config.machine.meta.ips.public.ipv6}]";
      type = "http";
      accepted_statuscodes = [ "200-299" ];
      notificationIDList = [ 1 ];
      headers = ''
        {
          "Host": "luj.fr"
        }
      '';
    };
  };

}
