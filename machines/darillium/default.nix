{
  pkgs,
  config,
  inputs,
  profiles,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.27";
    profiles = with profiles; [
      syncthing
      emacs
    ];
    syncthing.id = "CCOB6HQ-VXA5XTN-NIIDYCK-MQGHI6G-6G5BGOB-JEIDJXC-FWEPINX-NM2DHAH";

  };

  services.libinput.touchpad.tapping = false;

  programs.fuse.userAllowOther = true;

  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
    directories = [
      "/var/lib"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        mode = "0600";
      }
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    users.julien = {
      directories = [
        ".ssh"
        ".mozilla"
        ".config/mozilla"
        ".local/share/mozilla"
        ".local/state/mozilla"
        ".cache/mozilla"
        ".gnupg"
        ".local/share/direnv"
        ".local/share/atuin"
        ".claude"
        ".config/Signal"
        ".config/dconf"
        ".local/share/keyrings"
        ".config/noctalia"
        ".cache/noctalia"
        ".cache/mu"
        ".step"
        ".zotero"
        ".cache/zotero"
        "Zotero"
        "Maildir"
        "Documents"
        "Pictures"
        "dev"
      ];
    };
  };

  fileSystems."/persistent".neededForBoot = true;

  disko = import ./disko.nix;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  hardware.enableRedistributableFirmware = true;

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 disable_11be=Y
  '';

  # Fix a problem with the firmware
  systemd.services.iwlwifi-tso-fix = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K wlp0s20f3 tso off gso off";
    };
  };

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [
    "xe.enable_psr=0"
    "intel_idle.max_cstate=1"
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables = {
      OLLAMA_VULKAN = "1";
      OLLAMA_FLASH_ATTENTION = "0";
      GGML_VK_DISABLE_INTEGER_DOT_PRODUCT = "1";
    };
  };

  services.tailscale.enable = true;

  services.userborn.enable = true;

  networking.networkmanager.enable = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  boot.initrd = {
    luks.devices.crypted = {
      crypttabExtraOpts = [ "fido2-device=auto" ];
      bypassWorkqueues = true;
    };
    systemd.enable = true;
  };

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 16;
        systems = [
          "x86_64-linux"
        ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
      {
        hostName = "builder.luj.fr";
        maxJobs = 5;
        systems = [
          "x86_64-linux"
        ];
        sshUser = "remote";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }

    ];
  };

  programs.ssh.knownHosts."epyc.infra.newtype.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";

  programs.ssh.knownHosts."builder.luj.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2z+S1+Q1hvLP5BTr36ao/NTy4Szo2OGq2iguwL4/zp";

  environment.systemPackages = with pkgs; [
    android-tools
    tailscale
    brightnessctl
    sbctl
    wl-clipboard
    wlr-randr
    grim
    slurp
    kanshi
    fuzzel
    waylock
    swayidle
    xwayland-satellite
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  programs.reka =
    let
      emacs-config-pkgs = (import inputs.emacs-config).packages.${pkgs.system};
      emacs-config = emacs-config-pkgs.default;
      emacs-initEl = emacs-config-pkgs.initEl;
      emacs-earlyInitDir = emacs-config-pkgs.earlyInitDir;
      inherit (pkgs) reka;

      rekaAllDeps = [ reka ] ++ (reka.propagatedUserEnvPkgs or reka.propagatedBuildInputs or [ ]);
      rekaLoadFlags = lib.concatMapStrings (p: ''-L "${p}/share/emacs/site-lisp" '') rekaAllDeps;

      wrappedEmacs =
        pkgs.runCommand "emacs-with-reka"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta.mainProgram = "emacs";
          }
          ''
            mkdir -p $out/bin
            for f in ${emacs-config}/bin/*; do
              name="$(basename "$f")"
              case "$name" in
                emacsclient*)
                  # emacsclient doesn't support --eval/--init-directory at launch
                  ln -s "$f" "$out/bin/$name"
                  ;;
                *)
                  makeWrapper "$f" "$out/bin/$name" \
                    --add-flags '${rekaLoadFlags}' \
                    --add-flags '--eval "(require (quote reka))"' \
                    --add-flags '--eval "(reka-enable)"'
                  ;;
              esac
            done
            ln -s ${emacs-config}/share $out/share 2>/dev/null || true
          '';
    in
    {
      enable = true;
      debug = false;
      launchCommand = "${wrappedEmacs}/bin/emacs --init-directory ${emacs-earlyInitDir} --load ${emacs-initEl}";
    };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XKB_DEFAULT_LAYOUT = "fr";
    QT_QPA_PLATFORM = "wayland";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config.reka = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };

  services.gnome.at-spi2-core.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  system.stateVersion = "26.05";
}
