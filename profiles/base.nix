{
  pkgs,
  lib,
  config,
  ...
}:

{

  imports = [
    ../users/default.nix
    ../users/julien.nix
  ];

  luj.nix.enable = true;
  luj.secrets.enable = true;
  luj.ssh-server.enable = true;
  luj.programs.mosh.enable = true;
  luj.deployment.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console = {
    keyMap = lib.mkForce "fr";
    font = null;
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  programs.gnupg.agent.enable = true;
  networking.firewall.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  environment.systemPackages = with pkgs; [
    neovim
    #attic-client
    kitty
    tailscale
    step-cli
    comma-with-db
    nixos-firewall-tool
  ];

  environment.variables.EDITOR = "nvim";

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  networking.firewall.checkReversePath = "loose";

  services.tailscale.enable = true;

  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    package = pkgs.nix-index-with-db;
  };

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/persistent/etc/ssh/ssh_host_ed25519_key"
  ];

  machine.meta.zones.luj =
    lib.mkIf
      (lib.hasAttrByPath [
        "vpn"
        "ipv4"
      ] config.machine.meta.ips)
      {
        subdomains.${config.networking.hostName} = {
          A = [ config.machine.meta.ips.vpn.ipv4 ];
        };
      };

  system.nixos.label = "${config.system.nixos.release}-${
    let
      repo = builtins.fetchGit ../.;
    in
    repo.dirtyShortRev or repo.shortRev
  }";

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIByzCCAXKgAwIBAgIQAcJCOR+99m5v3dHWQw5m9jAKBggqhkjOPQQDAjAwMRIw
      EAYDVQQKEwlTYXVtb25OZXQxGjAYBgNVBAMTEVNhdW1vbk5ldCBSb290IENBMB4X
      DTIyMDQyNDIwMDE1MFoXDTMyMDQyMTIwMDE1MFowODESMBAGA1UEChMJU2F1bW9u
      TmV0MSIwIAYDVQQDExlTYXVtb25OZXQgSW50ZXJtZWRpYXRlIENBMFkwEwYHKoZI
      zj0CAQYIKoZIzj0DAQcDQgAE5Sk6vYJcYlh4aW0vAN84MWr84TTVTTdsM2s8skH6
      7fDsqNMb7FMwUMEAFwQRiADjYy3saU2Dogh2ESuB1dDFFqNmMGQwDgYDVR0PAQH/
      BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFO5iTfZiutpsM7ja
      mP3yuMIy6iNTMB8GA1UdIwQYMBaAFBWOQHe4eAeothQTmTNKiG/pAowGMAoGCCqG
      SM49BAMCA0cAMEQCICu8u19I7RMfnQ7t3QXHP5fdUm/fX/puqF+jYSf9SZEoAiBc
      oVcd0OfuAExWHhOMUZ0OV4bws9WCax333I+Pg4nDNw==
      -----END CERTIFICATE-----''
    ''
      -----BEGIN CERTIFICATE-----
      MIIBpTCCAUqgAwIBAgIRALevKnnElllot/cRNGjnUqUwCgYIKoZIzj0EAwIwMDES
      MBAGA1UEChMJU2F1bW9uTmV0MRowGAYDVQQDExFTYXVtb25OZXQgUm9vdCBDQTAe
      Fw0yMjA0MjQyMDAxNDlaFw0zMjA0MjEyMDAxNDlaMDAxEjAQBgNVBAoTCVNhdW1v
      bk5ldDEaMBgGA1UEAxMRU2F1bW9uTmV0IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggq
      hkjOPQMBBwNCAAQG356Ui437dBTSOiJILKjVkwrJMsXN3eba/T1N+IJeqRBfigo7
      BW9YZfs1xIbMZ5wL0Zc/DsSEo5xCC7j4YaXro0UwQzAOBgNVHQ8BAf8EBAMCAQYw
      EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUFY5Ad7h4B6i2FBOZM0qIb+kC
      jAYwCgYIKoZIzj0EAwIDSQAwRgIhALdsEqiRa4ak5Cnin6Tjnel5uOiHSjoC6LKf
      VfXtULncAiEA2gmqdr+ugFz5tvPdKwanroTiMTUMhhCRYVlQlyTApyQ=
      -----END CERTIFICATE-----''
  ];
}
