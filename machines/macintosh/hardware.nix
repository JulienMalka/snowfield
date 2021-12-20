{ config, pkgs, lib, ... }:
{

  boot = {
    initrd = {
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "sdhci_pci" ];
    };
    kernelParams = [ "acpi_backlight=native" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "acpi_call" "kvm-amd" "amdgpu" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableAllFirmware;
    opengl = {
      driSupport = lib.mkDefault true;
      driSupport32Bit = lib.mkDefault true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
    };
  };



  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3e01f61b-c580-4078-94be-192f7aed5c5a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2799-DF20";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/44dadc95-a61e-40db-93d7-ada237f1e53b"; }];



}
