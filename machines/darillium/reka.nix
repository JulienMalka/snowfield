# Reka — Emacs window manager for River.
# Adapted from TVL depot (code.tvl.fyi/tree/users/tazjin/nixos/modules/reka.nix).
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  debug = false;

  # Build Emacs with reka's elisp loaded and the window manager primed at
  # startup. Drives systemd's `ExecStart` below.
  wrappedEmacs =
    let
      emacs-config-pkgs = (import inputs.emacs-config).packages.${pkgs.system};
      emacs-config = emacs-config-pkgs.default;
      inherit (pkgs) reka;
      rekaAllDeps = [ reka ] ++ (reka.propagatedUserEnvPkgs or reka.propagatedBuildInputs or [ ]);
      rekaLoadFlags = lib.concatMapStrings (p: ''-L "${p}/share/emacs/site-lisp" '') rekaAllDeps;
    in
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

  emacs-config-pkgs = (import inputs.emacs-config).packages.${pkgs.system};
  emacs-initEl = emacs-config-pkgs.initEl;
  emacs-earlyInitDir = emacs-config-pkgs.earlyInitDir;

  launchCommand = "${wrappedEmacs}/bin/emacs --init-directory ${emacs-earlyInitDir} --load ${emacs-initEl}";

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
    exec ${launchCommand}
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
    Environment="RUST_LOG=${if debug then "DEBUG" else "INFO"}"
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
  security.polkit.enable = true;
  services.graphical-desktop.enable = true;

  systemd.packages = [ rekaSystemPackage ];
  services.displayManager.sessionPackages = [ rekaSystemPackage ];

  environment.systemPackages = [ rekaSystemPackage ];

  # waylock needs an empty PAM configuration
  security.pam.services.waylock = { };
}
