let
  inputs = import ./lon.nix;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  bootstrap = pkgs.callPackage scripts/bootstrap-machine.nix { inherit nixos-anywhere; };
  lon = pkgs.callPackage "${inputs.lon}/nix/packages/lon.nix" { };
  nixmoxer = pkgs.callPackage "${inputs.proxmox}/pkgs/nixmoxer" { };
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
    agenix
    bootstrap
    pkgs.statix
    lon
    nixmoxer
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
  '';
}
