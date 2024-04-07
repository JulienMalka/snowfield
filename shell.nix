let
  inputs = import ./deps;
  pkgs = import inputs.unstable { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  bootstrap = import scripts/bootstrap-machine.nix;
  pre-commit-hook = (import inputs.git-hooks).run {
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
    nixos-anywhere
    agenix
    bootstrap
    statix
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
  '';
}
