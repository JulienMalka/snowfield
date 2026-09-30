{ lib, modulesPath, ... }:

{
  # Google Compute Engine VM (n1-standard-2, europe-north1-a).
  imports = [ (modulesPath + "/virtualisation/google-compute-config.nix") ];

  # The VM was created from an image with its own disko layout, booting
  # systemd-boot over UEFI, not the GRUB setup google-compute-config assumes.
  fileSystems."/" = {
    device = lib.mkForce "/dev/disk/by-label/disk-main-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
  };
  boot.loader.grub.enable = false;

  # SSH access comes from snowfield's profiles like on every other machine,
  # not from GCP's OS Login.
  security.googleOsLogin.enable = lib.mkForce false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
