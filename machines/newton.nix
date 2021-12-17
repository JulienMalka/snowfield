{ config, pkgs, lib, modulesPath, ... }:
let
  hostName = "newton";
in
{


  luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.programs.git.enable = true;
    luj.emails = {
      enable = true;
      backend.enable = true;
    };
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.julienmalka.me"; # externally visible URL
    notificationSender = "hydra@localhost"; # e-mail of hydra service
    port = 9876; # Default
    # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
    buildMachinesFiles = [ ];
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
  };


  services.nginx = {
    enable = true;
    virtualHosts = {
      "hydra.julienmalka.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://127.0.0.1:9876"; };
      };
    };
  };
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = false;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.loader.grub.mirroredBoots = [
    { path = "/boot-1"; devices = [ "/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WCC4M1TVUVJV" ]; }
    { path = "/boot-2"; devices = [ "/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WCC4M7UDRLSK" ]; }
  ];

  programs.gnupg.agent.enable = true;
  networking.hostName = hostName; # Define your hostname.
  networking.hostId = "f7cdfbc9";

  time.timeZone = "Europe/Paris";

  networking.useDHCP = false;
  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp2s0f1.useDHCP = true;

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ /boot-1/initrd-ssh-key /boot-2/initrd-ssh-key ];
      authorizedKeys = lib.splitString "\n" 
    (builtins.readFile (pkgs.fetchurl {
      url = "https://github.com/JulienMalka.keys";
      sha256 = "sha256:2NLoT1/N6Y1uZQ+KLGeRLBPNkc4z3jrYrN9A4bCJWkU=";
    }));

    };
    postCommands = ''
      zpool import zroot
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };




  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;








 
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?


  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "tg3" "xhci_pci" "ahci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "zroot/root";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/boot-1" =
    {
      device = "/dev/disk/by-uuid/15AF-22DB";
      fsType = "vfat";
      options = [ "nofail" ];
    };

  fileSystems."/boot-2" =
    {
      device = "/dev/disk/by-uuid/15EC-BC00";
      fsType = "vfat";
      options = [ "nofail" ];
    };

  swapDevices = [ ];


  luj = {
    filerun.enable = true;
    zfs-mails.enable = true;
  };






}
