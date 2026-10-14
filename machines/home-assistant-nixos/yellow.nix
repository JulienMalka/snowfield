{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ "${inputs.nixos-hardware}/raspberry-pi/4" ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel.nix { inherit inputs; });

  hardware.raspberry-pi.firmware = {
    enable = true;
    path = "/boot";
    uboot = {
      enable = true;
      package = pkgs.callPackage ./uboot.nix { };
    };
    useGenerationDeviceTree = true;
  };

  hardware.raspberry-pi.configtxt = {
    settings = {
      all = {
        device_tree = "bcm2711-rpi-cm4-ha-yellow.dtb";
        disable_splash = true;
        gpu_mem = 32;
      };
      cm4.otg_mode = lib.mkForce null;
    };
    deviceTreeOverlays.all = lib.mkForce [ ];
  };

  boot.kernelParams = [
    "console=tty0"
    "console=ttyAMA2,115200n8"
    "coherent_pool=1M"
    "8250.nr_uarts=1"
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "mmc_block"
    "sdhci_iproc"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.initrd.allowMissingModules = true;
}
