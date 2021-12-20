{ pkgs, config, lib, ... }:
{
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/eaec3978-f462-4634-95e6-06d59512deb8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/EAD2-51DB";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c19ec918-ba8c-4bab-9ee0-831465cb432e"; }];



}
