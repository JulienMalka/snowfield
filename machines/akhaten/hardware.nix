{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.grub.enable = true;
  boot.initrd.availableKernelModules = [ "ahci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.postDeviceCommands = ''
    lvm lvremove --force /dev/mainpool/root || :
    yes | lvm lvcreate --size 100G --name root mainpool
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 /dev/mainpool/root
  '';

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
