{ pkgs, config, lib, ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = false;
  boot.kernelPackages = pkgs.linuxPackages_5_15;

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
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9Uzb7szWlux7HuxLZej9cBR5MhLz/vaAPPfSoozt2k"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCKfPoMNrnyNWH6J1OvQ+n1rvSS9Sc2iZf6E1JQC+L4"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESMWr29i3rhj32oLV3DKe57YI+jvNaKjZhhpq6dEjsn"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOCKgHRHAJDSgKqYNfWboL04mnEOM0m0K3TGxBhBNDR"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpGHx430EpJmbtJc8+lF1CpQ1gXeHT9OeZ08O8yzohF"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaCGndojnmS5IoqHVMEPRfKuBZotMyqo7wNkAZJWigp"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINqqbb91oMRg0L5kcljMhuKi4l2TjE/JKJQwcFVahDJH"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxfFq8wx5Bet5Q0gI28/lc9ryYYFQelpZdPPdzxGBbA"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr"
      ];
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
