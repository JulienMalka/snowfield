{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let

  stumpwmContrib = pkgs.fetchFromGitHub {
    owner = "stumpwm";
    repo = "stumpwm-contrib";
    rev = "1e3fa7abae30e5d5498e69ba56da6a7e265144cc";
    hash = "sha256-ewPeamcEWcvAHY1pmnbsVmej8gSt2qIo+lSMjpKwF6k=";

  };
  sbcl_stump = pkgs.sbcl_2_4_6;
  stumpwmWithDeps = sbcl_stump.pkgs.stumpwm.overrideLispAttrs (x: {
    lispLibs =
      x.lispLibs
      ++ (with sbcl_stump.pkgs; [
        clx-truetype
        slynk
      ]);
  });

  stumpwmWithDepsRunnable = pkgs.runCommand "stuumpwm-with-deps-runnable" { } ''
    mkdir -p "$out/bin" "$out/lib"
    cp -r "${stumpwmContrib}" "contrib"
    chmod u+rwX -R contrib
    export HOME="$PWD"
    FIRA_CODE_PATH="${pkgs.fira-code}/share/fonts/truetype"
    POWERLINE_PATH="${pkgs.powerline-fonts}/share/fonts/truetype"
    ln -s "${stumpwmWithDeps}" "$out/lib/stumpwm"
    ${(sbcl_stump.withPackages (_: [ stumpwmWithDeps ]))}/bin/sbcl \
        --eval '(require :asdf)'  --eval '(asdf:disable-output-translations)' \
        --eval '(require :stumpwm)' \
        --eval '(in-package :stumpwm)' \
        --eval '(setf *default-package* :stumpwm)' \
        --eval '(set-module-dir "contrib")' \
        --eval '(defvar stumpwm::*local-module-dir* "contrib")' \
        --eval '(load-module "mem")' \
        --eval '(load-module "cpu")' \
        --eval '(load-module "battery-portable")' \
        --eval '(load-module "net")' \
        --eval '(load-module "urgentwindows")' \
        --eval '(load-module "ttf-fonts")' \
        --eval '(require :slynk)' \
        --eval '(require :clx-truetype)' \
        --eval '(defvar *wallpaper* nil)' \
        --eval '(setf *wallpaper* "${./wallpaper.jpeg}")' \
        --eval "(setf clx-truetype:*font-dirs* (list \"$FIRA_CODE_PATH\" \"$POWERLINE_PATH\"))" \
        --eval "(sb-ext:save-lisp-and-die \"$out/bin/stumpwm\" :executable t :toplevel #'stumpwm:stumpwm)"
    test -x "$out/bin/stumpwm"
  '';
in
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./syncthing.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    # TODO: Fix colmena deployment
    ips.public.ipv4 = "127.0.0.1";
    ips.vpn.ipv4 = "100.100.45.11";
  };

  # Boot stuff
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.initrd.systemd.enable = true;
  boot.initrd.clevis = {
    enable = true;
    devices."cryptroot".secretFile = ./root.jwe;
  };
  boot.initrd.systemd.tpm2.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.stumpwm.enable = true;
    windowManager.stumpwm.package = stumpwmWithDepsRunnable;
  };

  services.picom = {
    enable = true;
    backend = "xr_glx_hybrid";
    vSync = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    wireplumber.enable = true;
  };

  networking.hostName = "fischer";

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables = {
    LIBSEAT_BACKEND = "logind";
  };

  services.tailscale.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  services.autorandr = {
    enable = true;
    profiles = {
      default = {
        fingerprint = {
          eDP-1-1 = "00ffffffffffff0006af9af900000000141f0104a51e13780363f5a854489d240e505400000001010101010101010101010101010101fa3c80b870b0244010103e002dbc1000001ac83080b870b0244010103e002dbc1000001a000000fe004a38335646804231343055414e0000000000024101b2001100000a410a20200068";
        };
        config = {
          eDP-1-1.enable = true;
        };
      };
      dock-julien = {
        fingerprint = {
          eDP-1-1 = "00ffffffffffff0006af9af900000000141f0104a51e13780363f5a854489d240e505400000001010101010101010101010101010101fa3c80b870b0244010103e002dbc1000001ac83080b870b0244010103e002dbc1000001a000000fe004a38335646804231343055414e0000000000024101b2001100000a410a20200068";
          DP-1-5-3 = "00ffffffffffff0010ac42d1425439312021010380351e78eaa3d5ab524f9d240f5054a54b008100b300d100714fa9408180d1c00101565e00a0a0a02950302035000f282100001a000000ff004446354c5459330a2020202020000000fc0044454c4c205032343233440a20000000fd00314b1d711c000a2020202020200107020318b14d010203071112161304141f051065030c001000023a801871382d40582c45000f282100001e011d8018711c1620582c25000f282100009e011d007251d01e206e2855000f282100001e7e3900a080381f4030203a000f282100001a00000000000000000000000000000000000000000000000000000000000000c1";
          DP-1-5-1 = "00ffffffffffff0026cd6b610f01010117210104a5351e783be725a8554ea0260d5054bfef80d140d100d1c0b30095009040818081c0565e00a0a0a02950302035000f282100001a000000ff0031323134383332333030313335000000fd00314b0f5a19000a202020202020000000fc00504c32343933510a202020202001c5020320f153101f051404131e1d121116150f0e030207060123097f0783010000394e00a0a0a02250302035000f282100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000079";
        };
        config = {
          eDP-1-1.enable = false;
          DP-1-5-1 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2560x1440";
          };
          DP-1-5-3 = {
            enable = true;
            position = "2560x0";
            mode = "2560x1440";
          };
        };
      };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  services.libinput.touchpad.tapping = false;

  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.nvidia = {

    modesetting.enable = true;
    powerManagement.enable = true;
    #powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    dynamicBoost.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  environment.variables = {
    # Required to run the correct GBM backend for nvidia GPUs on wayland
    GBM_BACKEND = "nvidia-drm";
    # Apparently, without this nouveau may attempt to be used instead
    # (despite it being blacklisted)
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Hardware cursors are currently broken on wlroots
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  boot.extraModprobeConfig =
    "options nvidia "
    + lib.concatStringsSep " " [
      # nvidia assume that by default your CPU does not support PAT,
      # but this is effectively never the case in 2023
      "NVreg_UsePageAttributeTable=1"
      # This is sometimes needed for ddc/ci support, see
      # https://www.ddcutil.com/nvidia/
      #
      # Current monitor does not support it, but this is useful for
      # the future
      "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
    ];

  boot.initrd.kernelModules = [ "nvidia" ];

  programs.dconf.enable = true;

  security.polkit.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.julien.extraGroups = [ "tss" ]; # tss group has access to TPM devices

  services.postgresql.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    wl-mirror
    texlive.combined.scheme-full
    mu
    stumpwmWithDepsRunnable
  ];

  networking.hosts = {
    "172.25.90.82" = [ "ducati-diavel" ];
  };

  services.printing = {
    enable = true;
    extraConf = ''
      JobPrivateAccess all
      JobPrivateValues none
    '';
    clientConf = ''
      ServerName localhost
      Encryption Required
      User jmalka
    '';
  };

  environment.variables = {
    CUPS_USER = "jmalka";
  };

  security.pam.services.swaylock = { };

  programs.ssh.startAgent = true;

  services.gnome.gnome-keyring.enable = true;

  services.openssh.extraConfig = ''
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    MaxAuthTries 20
  '';

  virtualisation.docker.enable = true;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "ebe7fbd4451442b0"
    ];
  };

  # Desktop environment
  programs.xwayland.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  system.stateVersion = "23.05";
}
