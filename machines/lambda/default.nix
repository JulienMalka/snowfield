{ config, pkgs, lib, ... }:
{


  imports = [ ../../users/status.nix ];
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # if you have a Raspberry Pi 2 or 3, pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "lambda";
  # A bunch of boot parameters needed for optimal runtime on RPi 3b+
  boot.kernelParams = [ "cma=256M" ];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=256
  '';
  environment.systemPackages = with pkgs; [
    libraspberrypi
    tinystatus
    git
  ];

  # File systems configuration for using the installer's partition layout


 nix.package = lib.mkForce pkgs.nixUnstable; 


  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };


  networking.interfaces.eth0.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "129.199.134.202";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "129.199.134.254";
  networking.nameservers = [ "8.8.8.8" ];
  
  services.timesyncd.enable = true;
  systemd.services.htpdate = {
      description = "htpdate daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/htpdate.pid";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.htpdate}/bin/htpdate"
          "-D -u nobody"
          "-a -s"
          "-l"
          "www.linux.org"
        ];
      };
    };

  documentation.nixos.enable = false;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  boot.cleanTmpDir = true;
  luj.status = {
    enable = true;
    nginx = {
      enable = true;
      subdomain = "status";
    };
  };
  # Configure basic SSH access
  services.openssh.enable = true;
  #  services.openssh.permitRootLogin = "yes";

  # Use 1GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [{ device = "/swapfile"; size = 1024; }];

  luj.hmgr.status = { };
}
