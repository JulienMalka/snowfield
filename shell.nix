let
  inputs = import ./deps;
  pkgs = import inputs.nixpkgs { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ colmena npins nixos-anywhere agenix ];
}


