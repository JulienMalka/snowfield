{ pkgs, config, lib, ... }:
{
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
 boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ /boot-1/initrd-ssh-key /boot-2/initrd-ssh-key ];
      authorizedKeys = lib.splitString "\n" 
    (builtins.readFile (pkgs.fetchurl {
      url = "https://github.com/JulienMalka.keys";
      sha256 = "sha256-nBgn7jOqi/nPHhTy3x/oirL+A4X2gbmwy1NXLZhV99M=";
    }));

    };
    postCommands = ''
      zpool import zroot
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };


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



}
