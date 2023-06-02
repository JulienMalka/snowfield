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

  networking.nameservers = [ "100.100.45.5" "9.9.9.9" ];
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };

  networking.hostName = "tower"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  luj.buildbot.enable = true;
  luj.nginx.enable = true;

  environment.systemPackages = [ pkgs.tailscale pkgs.attic ];

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
      HostName lambda.julienmalka.me
      User root
      Port 45
  '';



  networking.firewall.allowedTCPPorts = [ 80 443 1810 ];
  networking.firewall.allowedUDPPorts = [ 80 443 1810 ];

  system.stateVersion = "22.11"; # Did you read the comment?

}
