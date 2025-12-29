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

  boot.initrd.services.lvm.enable = true;

  boot.initrd.systemd.services.rollback-root = {
    description = "Wipe ephemeral root filesystem";
    wantedBy = [ "initrd.target" ];
    after = [ "dev-mainpool-root.device" ];
    before = [ "sysroot.mount" ];
    path = [ pkgs.e2fsprogs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkfs.ext4 -F /dev/mainpool/root
    '';
  };

  fileSystems."/persistent".neededForBoot = lib.mkForce true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
