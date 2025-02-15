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
    ./forgejo-runner.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    profiles = with profiles; [
      vm-simple-network
      server
      behind-sniproxy
    ];
    ips = {
      public.ipv4 = "82.67.34.230";
      local.ipv4 = "192.168.0.103";
      vpn.ipv4 = "100.100.45.9";
      public.ipv6 = "2a01:e0a:de4:a0e1:8ec7:b5d2:f663:a67a";
      vpn.ipv6 = "fd7a:115c:a1e0::9";
    };

  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "tower";

  networking.useNetworkd = true;

  luj.buildbot.enable = true;
  luj.nginx.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    git
  ];

  services.tailscale.enable = true;

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  console.keyMap = "fr";

  services.openssh.enable = true;

  programs.ssh.knownHosts."darwin-build-box.winter.cafe".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0io9E0eXiDIEHvsibXOxOPveSjUPIr1RnNKbUkw3fD";

  services.nginx.virtualHosts."photos.julienmalka.me" = {
    enableACME = true;
    forceSSL = true;
    root = "/srv/photos";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        sshUser = "root";
        sshKey = "/home/julien/.ssh/id_ed25519";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        speedFactor = 2;
      }
      {
        hostName = "darwin-build-box.winter.cafe";
        maxJobs = 4;
        sshKey = "/home/julien/.ssh/id_ed25519";
        sshUser = "julienmalka";
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Host lambda
      IdentityFile /home/julien/.ssh/id_ed25519
      HostName lambda.luj
      User root
      Port 45
  '';

  services.nix-gitlab-runner = {
    enable = true;
    registrationConfigFile = "/var/lib/gitlab-runner/gitlab_runner";
    packages = with pkgs; [
      coreutils
      su
      bash
      git
    ];
  };

  services.nginx.virtualHosts."phd.julienmalka.me" = {
    basicAuthFile = "/home/gitlab-runner/nginx_auth";
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      autoindex on;
      autoindex_localtime on;
    '';
    root = "/home/gitlab-runner/artifacts";
  };

  machine.meta.probes.monitors."phd.julienmalka.me - IPv4".accepted_statuscodes = [ "401" ];
  machine.meta.probes.monitors."phd.julienmalka.me - IPv6".accepted_statuscodes = [ "401" ];

  systemd.services.nginx.serviceConfig.ProtectHome = "read-only";
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/home/gitlab-runner/artifacts" ];

  services.grafana.enable = true;
  services.grafana.settings.server.http_port = 3000;
  services.prometheus = {
    enable = true;
    pushgateway.enable = true;
    scrapeConfigs = [
      {
        job_name = "push";
        static_configs = [ { targets = [ "127.0.0.1:9091" ]; } ];
      }
    ];
  };

  services.nginx.virtualHosts."data.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."prometheus.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:9090";
    };
  };

  services.nginx.virtualHosts."push.julienmalka.me" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:9091";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    1810
    9989
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
    1810
    9989
  ];

  system.stateVersion = "22.11"; # Did you read the comment?
}
