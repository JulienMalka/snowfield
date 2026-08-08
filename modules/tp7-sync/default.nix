# tp7-sync — hands-free recording sync for Teenage Engineering field recorders.
#
# The recorder only exposes its storage after being asked, over a vendor SysEx
# message, to re-enumerate as an MTP device — and that switch truncates
# whatever it happens to be recording. The daemon watches the transport over
# MIDI and only reaches for the storage while the device is idle.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tp7-sync;

  settingsFile = (pkgs.formats.toml { }).generate "tp7-sync.toml" cfg.settings;
  arguments = lib.optionalString (cfg.settings != { }) "--config ${settingsFile}";

  # Two problems are solved here, and they interact.
  #
  # Access: these recorders present MTP as vendor class ff/01/01 rather than
  # the still-image class, so systemd's stock uaccess rule — which matches
  # ID_USB_INTERFACES on "*:060101:*" — never fires for them.
  #
  # Contention: when the recorder re-enumerates as MTP, gvfs claims the USB
  # interface within milliseconds and tp7-sync then cannot. Nothing can
  # preempt it, since the kernel will not evict another usbfs client. Clearing
  # ID_MEDIA_PLAYER is what keeps gvfs away, but it is also the property
  # libmtp's rules use to grant uaccess — hence the explicit tag, plus the
  # group for services that have no seat session at all.
  #
  # The 70- prefix is load-bearing: uaccess is dispatched from
  # 73-seat-late.rules, so services.udev.extraRules (99-local.rules) would tag
  # too late to have any effect.
  udevRules = pkgs.writeTextFile {
    name = "tp7-sync-udev-rules";
    destination = "/lib/udev/rules.d/70-tp7-sync.rules";
    text = ''
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2367", \
        TAG+="uaccess", MODE="0660", GROUP="${cfg.group}"

      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2367", \
        ENV{ID_MTP_DEVICE}="", ENV{ID_MEDIA_PLAYER}="", ENV{ID_GPHOTO2}="", \
        ENV{UDISKS_IGNORE}="1"
    '';
  };

  hardening = {
    Restart = "always";
    RestartSec = 5;

    # Reaches USB and its destination directory, nothing else. PrivateDevices
    # is deliberately absent: it would hide /dev/bus/usb. PrivateNetwork is
    # too, and must be: udev hotplug events arrive over a netlink socket that
    # is scoped to the network namespace, so isolating the network silently
    # stops the watcher ever seeing a device plugged in. Deny IP traffic
    # instead — that leaves netlink alone.
    IPAddressDeny = "any";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    MemoryDenyWriteExecute = true;
    SystemCallFilter = [ "@system-service" ];
  };
in

{
  options.services.tp7-sync = {
    enable = lib.mkEnableOption "the Teenage Engineering recording sync daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tp7-sync;
      defaultText = lib.literalExpression "pkgs.tp7-sync";
      description = "tp7-sync package to run.";
    };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "julien";
      description = ''
        Run as a system service owned by this user, rather than as a
        per-session user service.

        Use this on machines with no graphical login: the default user service
        only starts once a session does, and the uaccess tag it relies on
        grants an ACL tied to an active seat. A system service has neither, so
        it reaches the device through {option}`services.tp7-sync.group` — make
        sure this user is a member.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "audio";
      description = ''
        Group granted access to the recorder by the udev rule. Members can
        read recordings off it.
      '';
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the watcher automatically. Set to false to install the command
        and udev rules only.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = lib.literalExpression ''
        {
          destination = "/home/julien/Recordings/tp7";
          settle = "30s";
        }
      '';
      description = ''
        Contents of config.toml. Every setting has a working default; see
        `config.example.toml` in the package for the full list.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ udevRules ];

    systemd.services.tp7-sync = lib.mkIf (cfg.user != null) {
      description = "Teenage Engineering recording sync";
      wantedBy = lib.optional cfg.autoStart "multi-user.target";
      after = [ "systemd-udevd.service" ];

      serviceConfig = hardening // {
        ExecStart = "${lib.getExe cfg.package} ${arguments} watch";
        User = cfg.user;
        SupplementaryGroups = [ cfg.group ];
        StateDirectory = "tp7-sync";
      };
    };

    systemd.user.services.tp7-sync = lib.mkIf (cfg.user == null) {
      description = "Teenage Engineering recording sync";
      wantedBy = lib.optional cfg.autoStart "default.target";

      serviceConfig = hardening // {
        ExecStart = "${lib.getExe cfg.package} ${arguments} watch";
      };
    };
  };
}
