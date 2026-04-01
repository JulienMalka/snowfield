# Reka — Emacs-based window manager for River
{
  rekaSrc ? fetchgit {
    url = "https://codeberg.org/tazjin/reka.git";
    rev = "70aa8d95d96ff6ad4563fc29ed6d6ab0e9b486a1";
    hash = "sha256-brm+/9k4O/+xXdfXmV4vEQ8/yBo8xJZwyvldp6eVhPM=";
  },
  lib,
  fetchgit,
  rustPlatform,
  pkg-config,
  emacs-pgtk,
  libxkbcommon,
  ...
}:
let
  rekaModule = rustPlatform.buildRustPackage {
    name = "libreka";
    src = rekaSrc;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      emacs-pgtk
      libxkbcommon
    ];
    cargoLock.lockFile = "${rekaSrc}/Cargo.lock";
    postInstall = ''
      mkdir -p $out/share/emacs/site-lisp
      ln -s $out/lib/libreka.so $out/share/emacs/site-lisp/libreka.so
    '';
  };
in
emacs-pgtk.pkgs.trivialBuild {
  pname = "reka";
  version = "0.1";
  src = "${rekaSrc}/lisp";
  packageRequires = [ rekaModule ];

  meta = {
    description = "Emacs-based window manager for River";
    homepage = "https://codeberg.org/tazjin/reka";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
