{
  config,
  pkgs,
  inputs,
  profiles,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
    ];
    ips = {
      public.ipv4 = "82.67.34.230";
      local.ipv4 = "192.168.0.101";
      vpn.ipv4 = "100.100.45.28";
      public.ipv6 = "2a01:e0a:de4:a0e1:95c9:b2e2:e999:1a45";
      vpn.ipv6 = "fd7a:115c:a1e0::1c";
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  deployment.tags = [ "server" ];

  luj.nginx.enable = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    https = true;
    hostName = "nuage.malka.family";
    settings.overwriteProtocol = "https";
    config = {
      dbtype = "mysql";
      dbuser = "test";
      dbhost = "localhost"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nuage";
      dbpassFile = "/srv/nextclouddbpass";
      adminpassFile = "/srv/nextcloudadminpass";

      adminuser = "admin";
    };
  };

  virtualisation = {
    podman = {
      enable = true;

      defaultNetwork.settings = {
        dns_enable = true;
        ipv6_enabled = true;
      };
    };
  };

  virtualisation.oci-containers = {
    containers.collabora = {
      image = "collabora/code";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "collabora/code";
        imageDigest = "sha256:07da8a191b37058514dfdf921ea8c2270c6634fa659acee774cf8594f86950e4";
        sha256 = "sha256-5oaz07NQScHUVN/HznzZGQ2bGrU/V1GhI+9btXHz0GM=";
      };
      ports = [ "9980:9980" ];
      environment = {
        domain = "nuage.malka.family";
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true --o:remote_font_config.url=https://cloud.dgnum.eu/apps/richdocuments/settings/fonts.json";
      };
      extraOptions = [
        "--network=host"
        "--cap-add"
        "MKNOD"
        "--cap-add"
        "SYS_ADMIN"
      ];
    };
  };

  services.nginx.virtualHosts = {

    "collabora.luj.fr" = {
      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        # static files
        location ^~ /browser {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Host $host;
        }

        # WOPI discovery URL
        location ^~ /hosting/discovery {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Host $host;
        }

        # Capabilities
        location ^~ /hosting/capabilities {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Host $host;
        }

        # main websocket
        location ~ ^/cool/(.*)/ws$ {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 36000s;
        }

        # download, presentation and image upload
        location ~ ^/(c|l)ool {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Host $host;
        }

        # Admin Console websocket
        location ^~ /cool/adminws {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 36000s;
        }
      '';
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

  system.stateVersion = "22.05";
}
