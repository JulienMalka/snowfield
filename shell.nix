let
  inputs = import ./lon.nix;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  ragenixSrc = builtins.fetchGit {
    url = "git+ssh://git@github.com/geosurge-ai/ragenix.git";
    rev = "7bcb863c1ca86bac082f7a46c9ba945a9b4bbeb9";
    allRefs = true;
  };
  ragenix = pkgs.ragenix.overrideAttrs (_: {
    src = ragenixSrc;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = ragenixSrc;
      hash = "sha256-liimzFjEqgwB15VUfcwu1CRFEeDyXJ6fsH3pzfUPeKo=";
    };
  });
  bootstrap = pkgs.callPackage scripts/bootstrap-machine.nix { inherit nixos-anywhere; };
  snowfield = pkgs.callPackage scripts/snowfield.nix { };
  lon = pkgs.callPackage "${inputs.lon}/nix/packages/lon.nix" { };
  ci = import ./ci.nix;
  pre-commit-hook =
    (import (
      pkgs.applyPatches {
        name = "patched-git-hooks";
        src = inputs.git-hooks;
      }
    )).run
      {
        src = ./.;

        hooks = {
          statix = {
            enable = true;
            settings.ignore = [
              "**/lon.nix"
            ];
          };
          deadnix.enable = true;
          rfc101 = {
            enable = true;
            name = "RFC-101 formatting";
            entry = "${pkgs.lib.getExe pkgs.nixfmt-rfc-style}";
            files = "\\.nix$";
          };
          commitizen.enable = true;
        };
      };
in
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.colmena
    pkgs.rbw
    ragenix
    bootstrap
    snowfield
    pkgs.statix
    lon
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
    ${ci.workflowInstall.shellHook}
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
    export RULES="$repo_root/private/secrets/secrets.nix"
  '';
}
