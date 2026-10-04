{
  pkgs,
  inputs,
  profiles,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./nsd.nix
    ./mullvad.nix
    ./borg.nix
    ./readeck.nix
    ./plausible.nix
    ./nextcloud.nix
    ./artiflakery.nix
    ./josh.nix
    ./cal-proxy.nix
    ./cal-diy.nix
    ./niks3.nix
    ./luj-website.nix
    ./windmill.nix
    ./lasuite-meet.nix
    ./litellm.nix
    ./open-webui.nix
    ./terminus.nix
    ./wm-detector.nix
  ];

  users.users.julien.linger = true;

  boot.initrd.systemd.enable = true;

  # What gustave itself backs up
  services.backup.includes = [ "/home/julien/Maildir" ];

  # Identity
  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    syncthing.id = "3LPQQ6G-JO4M5FH-EDGCLDO-VN2J3PR-DDPB7IS-447IUF3-BHIS6S4-NQMWNQD";
    profiles = with profiles; [
      vm-simple-network
      server
      behind-sniproxy
      syncthing
      monitoring
    ];
    ips = {
      public.ipv4 = "77.42.114.11";
      local.ipv4 = "192.168.0.90";
      vpn.ipv4 = "100.100.45.24";
      public.ipv6 = "2a01:4f9:3090:2b8c:eb2:aaaa::45";
      vpn.ipv6 = "fd7a:115c:a1e0::18";
    };

  };

  # Docs and odd proxies
  luj.docs = {
    enable = true;
    subdomain = "docs";
  };

  services.nginx.virtualHosts."staging-lila.luj.fr" = {
    locations."/" = {
      proxyPass = "http://localhost:8004";
    };
  };

  services.nginx.virtualHosts."slack-bot.luj.fr" = {
    locations."/" = {
      proxyPass = "http://localhost:8005";
    };
  };

  # Boot and plumbing
  security.polkit.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.fuse.userAllowOther = true;

  deployment.tags = [ "server" ];

  disko = import ./disko.nix;

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];

  # The forge
  services.forgejo = {
    enable = true;
    package = pkgs.unstable.forgejo;
    database.type = "postgres";
    settings = {
      server = {
        ROOT_URL = "https://git.luj.fr/";
        LANDING_PAGE = "luj";
      };
      #openid.ENABLE_OPENID_SIGNIN = true;
      openid.ENABLE_OPENID_SIGNUP = true;
      oauth2_client.REGISTER_EMAIL_CONFIRM = false;
      oauth2_client.ENABLE_AUTO_REGISTRATION = true;
      oauth2_client.UPDATE_AVATAR = true;
      oauth2_client.ACCOUNT_LINKING = "auto";
      service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
    };
  };

  services.openssh.ports = [ 22 ];
  services.openssh.settings.PerSourcePenaltyExemptList = "2001:bc8:38ee:100:f837:7fff:fe77:7154";

  services.nginx.virtualHosts."git.luj.fr" = {
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };

  # Surviving reboots
  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
    directories = [
      {
        directory = "/var/lib";
        inInitrd = true;
      }
      { directory = "/var/log"; }
      {
        directory = "/srv";
        inInitrd = true;
      }
    ];
    files = [
      "/etc/machine-id"
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        mode = "0600";
      }
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key-cert.pub"
    ];
    users.julien = {
      directories = [
        ".ssh"
        ".local/share/direnv"
        ".gnupg"
        ".local/share/keyrings"
        "Maildir"
      ];
    };
  };

  # Odds and ends
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  luj.irc = {
    enable = true;
    subdomain = "irc";
  };

  luj.homepage.enable = true;
  luj.mediaserver = {
    enable = true;
    tv.enable = true;
    music.enable = false;
  };
  luj.deluge.interface = "wg0";

  # Webmail
  services.roundcube = {
    enable = true;
    plugins = [
      "managesieve"
    ];
    hostName = "webmail.luj.fr";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://mail.luj.fr";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['imap_host'] = 'ssl://mail.luj.fr';
    '';
  };

  system.stateVersion = "23.11";
}
