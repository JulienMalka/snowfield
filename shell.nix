let
  inputs = import ./deps;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  bootstrap = pkgs.callPackage scripts/bootstrap-machine.nix { inherit nixos-anywhere; };
  update-deps = pkgs.callPackage scripts/update-deps.nix { };
  pre-commit-hook =
    (import (
      pkgs.applyPatches {
        name = "patched-git-hooks";
        src = inputs.git-hooks;
        patches = [ ./patches/hooks-correct-nixfmt.patch ];
      }
    )).run
      {
        src = ./.;

        hooks = {
          statix.enable = true;
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
  nativeBuildInputs = with pkgs; [
    colmena
    npins
    agenix
    bootstrap
    update-deps
    statix
    rbw
    pinentry
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
  '';
}
