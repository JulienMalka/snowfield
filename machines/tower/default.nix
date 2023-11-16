{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.resolved.enable = true;
  networking.hostName = "tower"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  luj.buildbot.enable = true;
  luj.nginx.enable = true;

  environment.systemPackages = with pkgs; [ tailscale colmena ];

  services.tailscale.enable = true;

  nix.extraOptions = ''
    allow-import-from-derivation = true
      experimental-features = nix-command flakes
  '';

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  console.keyMap = "fr";

  users.users.julien = {
    isNormalUser = true;
    description = "Julien";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [ ];
  };

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "i686-linux" ];

  programs.ssh.knownHosts."darwin-build-box.winter.cafe".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0io9E0eXiDIEHvsibXOxOPveSjUPIr1RnNKbUkw3fD";


  nix = {
    package = lib.mkForce pkgs.nix;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [ "x86_64-linux" ];
        sshUser = "root";
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
      {
        hostName = "lambda";
        maxJobs = 4;
        systems = [ "aarch64-linux" ];
        supportedFeatures = [ "big-parallel" ];
      }
      {
        hostName = "darwin-build-box.winter.cafe";
        maxJobs = 4;
        sshKey = "/home/julien/.ssh/id_ed25519";
        sshUser = "julienmalka";
        systems = [ "aarch64-darwin" "x86_64-darwin" ];
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
    packages = with pkgs; [ coreutils su bash git ];
  };



  services.nginx.virtualHosts."phd.julienmalka.me" = {
    enableACME = true;
    forceSSL = true;
    root = "/home/gitlab-runner/artifacts";
  };


  services.grafana.enable = true;
  services.grafana.settings.server.http_port = 3000;
  services.prometheus = {
    enable = true;
    pushgateway.enable = true;
    scrapeConfigs = [
      {
        job_name = "push";
        static_configs = [{
          targets = [ "127.0.0.1:9091" ];
        }];
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



  networking.firewall.allowedTCPPorts = [ 80 443 1810 9989 ];
  networking.firewall.allowedUDPPorts = [ 80 443 1810 9989 ];

  system.stateVersion = "22.11"; # Did you read the comment?

}
