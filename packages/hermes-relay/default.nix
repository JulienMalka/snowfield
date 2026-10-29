{
  python3Packages,
  # The flake input of the same name: the assistant-app repository, whose
  # relay/ is the service.
  src,
}:

python3Packages.callPackage "${src}/relay/default.nix" { }
