{ config, lib, ... }:

{
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot.initrd.kernelModules = [ "nvidia" ];

  boot.extraModprobeConfig =
    "options nvidia "
    + lib.concatStringsSep " " [
      # nvidia assumes the CPU doesn't support PAT by default, but every
      # relevant chip does.
      "NVreg_UsePageAttributeTable=1"
      # Needed for ddc/ci support on some monitors — see
      # https://www.ddcutil.com/nvidia/. The current display doesn't use it
      # but leaving it on is harmless.
      "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
    ];

  environment.variables = {
    # Correct GBM backend for nvidia under wayland.
    GBM_BACKEND = "nvidia-drm";
    # Prevent nouveau from being auto-loaded despite the blacklist.
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Hardware cursors are currently broken on wlroots with nvidia.
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
