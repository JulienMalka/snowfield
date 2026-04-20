# Reka — Emacs window manager for River
# Adapted from TVL depot (code.tvl.fyi/tree/users/tazjin/nixos/modules/reka.nix)
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.reka;

  rekaSession = pkgs.writeShellScript "reka-session" ''
    # Re-exec through a login shell to get the full NixOS environment
    if [ -n "$SHELL" ] &&
       grep -q "$SHELL" /etc/shells &&
       ! (echo "$SHELL" | grep -q "false") &&
       ! (echo "$SHELL" | grep -q "nologin"); then
      if [ "$1" != '-l' ]; then
        exec bash -c "exec -l '$SHELL' -c '$0 -l $*'"
      else
        shift
      fi
    fi

    if systemctl --user -q is-active reka.service; then
      echo 'reka is already running.'
      exit 1
    fi

    systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --all
    fi

    systemctl --user --wait start reka.service

    # Force stop of graphical-session.target on exit
    systemctl --user start --job-mode=replace-irreversibly reka-shutdown.target

    # Clean up environment
    systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
  '';

  rekaDesktop = pkgs.writeText "reka.desktop" ''
    [Desktop Entry]
    Name=reka
    Comment=reka, emacs for river
    Exec=reka-session
    Type=Application
    DesktopNames=reka
  '';

  wonkyLaunchCommand = pkgs.writeShellScript "reka-launch" ''
    systemctl --user import-environment WAYLAND_DISPLAY
    ${pkgs.systemd}/bin/systemd-notify --ready
    exec ${cfg.launchCommand}
  '';

  rekaUnit = pkgs.writeText "reka.service" ''
    [Unit]
    Description=reka, emacs for river
    BindsTo=graphical-session.target
    Before=graphical-session.target
    Wants=pipewire.service graphical-session-pre.target
    After=pipewire.service graphical-session-pre.target

    Wants=xdg-desktop-autostart.target
    Before=xdg-desktop-autostart.target

    [Service]
    Slice=session.slice
    Type=notify
    NotifyAccess=all
    WorkingDirectory=%h
    Environment="RUST_LOG=${if cfg.debug then "DEBUG" else "INFO"}"
    ExecStart=${pkgs.river}/bin/river -c ${wonkyLaunchCommand}
  '';

  rekaShutdown = pkgs.writeText "reka-shutdown.target" ''
    [Unit]
    Description=Shutdown running reka session
    DefaultDependencies=no
    StopWhenUnneeded=true
    Conflicts=graphical-session.target graphical-session-pre.target
    After=graphical-session.target graphical-session-pre.target
  '';

  rekaSystemPackage =
    pkgs.runCommand "reka-system"
      {
        passthru.providedSessions = [ "reka" ];
      }
      ''
        install -Dm755 ${rekaSession} $out/bin/reka-session
        install -Dm644 ${rekaDesktop} $out/share/wayland-sessions/reka.desktop
        install -Dm644 ${rekaUnit} $out/lib/systemd/user/reka.service
        install -Dm644 ${rekaShutdown} $out/lib/systemd/user/reka-shutdown.target
      '';
in
{
  options.programs.reka = {
    enable = lib.mkEnableOption "reka, an Emacs window manager for river";
    debug = lib.mkEnableOption "debug logging for reka";

    launchCommand = lib.mkOption {
      type = lib.types.str;
      description = "Fully configured Emacs launch command (passed to river -c)";
    };
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;
    services.graphical-desktop.enable = true;

    systemd.packages = [ rekaSystemPackage ];
    services.displayManager.sessionPackages = [ rekaSystemPackage ];

    environment.systemPackages = [
      rekaSystemPackage
    ];

    # waylock needs an empty PAM configuration
    security.pam.services.waylock = { };
  };
}
