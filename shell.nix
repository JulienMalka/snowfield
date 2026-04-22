let
  inputs = import ./lon.nix;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  # ragenix from nixpkgs. If you need a local fork, override via shell.nix in
  # a gitignored file or re-add the fetchGit here.
  ragenix = pkgs.ragenix;
  bootstrap = pkgs.callPackage scripts/bootstrap-machine.nix { inherit nixos-anywhere; };
  snowfield = pkgs.callPackage scripts/snowfield.nix { };
  lon = pkgs.callPackage "${inputs.lon}/nix/packages/lon.nix" { };
  niks3 = pkgs.callPackage "${inputs.niks3}/nix/packages/niks3.nix" { };
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
            entry = "${pkgs.lib.getExe pkgs.nixfmt}";
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
    niks3
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
    ${ci.workflowInstall.shellHook}
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
    export RULES="$repo_root/secrets/secrets.nix"
  '';
}
