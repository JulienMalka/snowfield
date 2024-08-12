{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs_patched;
    hm_version = inputs.home-manager-unstable;
    # TODO: Fix colmena deployment
    ips.public.ipv4 = "127.0.0.1";

  };

  # Lanzaboote 
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # Automatic root partition decryption with TPM2
  boot.initrd = {
    systemd = {
      enable = true;
      enableTpm2 = true;
    };
    clevis = {
      enable = true;
      devices."/dev/nvme0n1p1".secretFile = ./root.jwe;
    };
  };

  # Sound
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.pulseaudio.enable = lib.mkForce false;

  services.postgresql.enable = true;

  networking.wireless.enable = false;

  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.logind.lidSwitch = "suspend";

  services.tailscale.enable = true;
  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = null;
    useXkbConfig = true; # use xkbOptions in tty.
  };

  hardware.graphics.enable = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  services.tlp.enable = false;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.julien.extraGroups = [ "tss" ]; # tss group has access to TPM devices

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [ "x86_64-linux" ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    wl-mirror
  ];

  networking.wireguard.interfaces.rezo = {
    ips = [ "fd81:fb3a:50cc::200/128" ];
    privateKeyFile = "/root/wg-private";
    peers = [
      {
        publicKey = "srQPT9ZjXBKyJ7R1mvXYMZNy+NcnHMy5qE1WGZDfmnc=";
        allowedIPs = [ "fd81:fb3a:50cc::/48" ];
        endpoint = "129.199.146.230:25351";
      }
    ];
  };

  security.pam.services.swaylock = { };

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  programs.ssh.startAgent = true;

  services.gnome.gnome-keyring.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
    "zotero-6.0.27"
  ];

  services.hash-collection = {
    enable = true;
    collection-url = "https://reproducibility.nixos.social";
    tokenFile = "/home/julien/lila-secrets/tokenfile";
    secretKeyFile = "/home/julien/lila-secrets/secret.key";
  };

  nix.settings = {
    post-build-hook = lib.mkForce (
      pkgs.writeScript "hash-collection-build-hook" ''
        #!/bin/sh
        export HASH_COLLECTION_SERVER=${config.services.hash-collection.collection-url}
        export HASH_COLLECTION_TOKEN=$(cat ${toString config.services.hash-collection.tokenFile})
        export HASH_COLLECTION_SECRET_KEY=$(cat ${toString config.services.hash-collection.secretKeyFile})

        # redirect stderr to stdout, otherwise it appears to go missing?
        ${pkgs.lila-build-hook}/bin/build-hook 2>&1
      ''
    );
  };

  # Desktop environment
  programs.xwayland.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
  };

  system.stateVersion = "23.05";
}
