let
  inputs = import ./lon.nix;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  bootstrap = pkgs.callPackage scripts/bootstrap-machine.nix { inherit nixos-anywhere; };
  lon = pkgs.callPackage "${inputs.lon}/nix/packages/lon.nix" { };
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
    agenix
    bootstrap
    pkgs.statix
    lon
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
    export RULES="$repo_root/private/secrets/secrets.nix"
  '';
}
