{
  pkgs,
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

  fileSystems."/persistent".neededForBoot = true;

  disko = import ./disko.nix;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  boot.loader.systemd-boot.enable = true;

  networking.wireless.enable = false;

  services.tailscale.enable = true;

  services.userborn.enable = true;

  networking.networkmanager.enable = true;

  services.dbus.enable = true;

  programs.dconf.enable = true;

  boot.initrd = {
    luks.devices.crypted = {
      crypttabExtraOpts = [ "fido2-device=auto" ];
    };
    systemd.enable = true;

  };

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
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
    tailscale
    brightnessctl
    sbctl
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
  };

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xterm.enable = true;
  services.xserver.enable = true;
  services.xserver.autoRepeatDelay = 250;
  services.xserver.autoRepeatInterval = 30;

  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
      EMACS_EXWM=1 ${(import inputs.emacs-config).packages.${pkgs.system}.default}/bin/emacs
    '';
  };

  services.autorandr = {
    enable = true;
    profiles = {
      mobile = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff0009e5ca0c0000000003220104a51e1378071eeba3564d9b240d515400000001010101010101010101010101010101333f80dc70b03c40302036002ebc1000001a000000fd00283c4c4c10010a202020202020000000fe00424f452043510a202020202020000000fc004e4531343057554d2d4e364d0a01a37020790200250109f77702f77702283c80810015741a00000301283c00006a496a493c000000008d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b790";
        };
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1200";
          };
        };
      };
      docked = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff0009e5ca0c0000000003220104a51e1378071eeba3564d9b240d515400000001010101010101010101010101010101333f80dc70b03c40302036002ebc1000001a000000fd00283c4c4c10010a202020202020000000fe00424f452043510a202020202020000000fc004e4531343057554d2d4e364d0a01a37020790200250109f77702f77702283c80810015741a00000301283c00006a496a493c000000008d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b790";
          "DP-1-1" =
            "00ffffffffffff0010acbca1425051302821010380351e78ee9025ac524f9e250f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff00444744574e4d330a2020202020000000fc0044454c4c20553234323248450a000000fd00384c1e5311000a20202020202001a202031ff14c0005040302071601141f1213230907078301000065030c001000023a801871382d40582c45000f282100001e011d8018711c1620582c25000f282100009e011d007251d01e20462855000f282100001e8c0ad08a20e02d10103e96000f2821000018000000000000000000000000000000000000000000000000ef";
          "DP-1-2" =
            "00ffffffffffff00220e6234010101012f1d0104a53420783a5595a9544c9e240d5054a10800b30095008100d1c0a9c081c0a9408180283c80a070b023403020360006442100001a000000fd00323c1e5011010a202020202020000000fc0048502045323433690a20202020000000ff0036434d393437303658350a20200011";
        };
        config = {
          "eDP-1".enable = false;
          "DP-1-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
          "DP-1-2" = {
            enable = true;
            position = "1920x0";
            mode = "1920x1200";
          };
        };
      };
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  services.gnome.gnome-keyring.enable = true;
  system.stateVersion = "26.05";
}
