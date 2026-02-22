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

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
