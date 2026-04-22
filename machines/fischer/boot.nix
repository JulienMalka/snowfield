{ lib, ... }:

{
  # lanzaboote takes over from systemd-boot so the signed kernel chain works.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;

  # TPM-backed root decryption via clevis; the JWE holds the sealed secret.
  boot.initrd.clevis = {
    enable = true;
    devices."cryptroot".secretFile = ./root.jwe;
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
}
