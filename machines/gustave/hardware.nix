{
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.postDeviceCommands = ''
    lvm lvremove --force /dev/mainpool/root || :
    yes | lvm lvcreate --size 100G --name root mainpool
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 /dev/mainpool/root
  '';

  fileSystems."/persistent".neededForBoot = lib.mkForce true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
