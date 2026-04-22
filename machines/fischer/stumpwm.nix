{ pkgs, ... }:

let
  stumpwmContrib = pkgs.fetchFromGitHub {
    owner = "stumpwm";
    repo = "stumpwm-contrib";
    rev = "1e3fa7abae30e5d5498e69ba56da6a7e265144cc";
    hash = "sha256-ewPeamcEWcvAHY1pmnbsVmej8gSt2qIo+lSMjpKwF6k=";
  };

  sbclStump = pkgs.sbcl_2_4_6;

  stumpwmWithDeps = sbclStump.pkgs.stumpwm.overrideLispAttrs (old: {
    lispLibs = old.lispLibs ++ [
      sbclStump.pkgs.clx-truetype
      sbclStump.pkgs.slynk
    ];
  });

  stumpwmWithDepsRunnable = pkgs.runCommand "stumpwm-with-deps-runnable" { } ''
    mkdir -p "$out/bin" "$out/lib"
    cp -r "${stumpwmContrib}" "contrib"
    chmod u+rwX -R contrib
    export HOME="$PWD"
    FIRA_CODE_PATH="${pkgs.fira-code}/share/fonts/truetype"
    POWERLINE_PATH="${pkgs.powerline-fonts}/share/fonts/truetype"
    ln -s "${stumpwmWithDeps}" "$out/lib/stumpwm"
    ${(sbclStump.withPackages (_: [ stumpwmWithDeps ]))}/bin/sbcl \
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
  services.xserver.windowManager.stumpwm.enable = true;
  services.xserver.windowManager.stumpwm.package = stumpwmWithDepsRunnable;
  environment.systemPackages = [ stumpwmWithDepsRunnable ];
}
