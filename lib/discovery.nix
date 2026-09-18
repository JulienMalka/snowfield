# Discover only supported entry points, so documentation and editor files can
# live beside modules without becoming accidental Nix imports.
{ lib }:
{
  directories =
    path:
    lib.filterAttrs (
      name: kind: kind == "directory" && builtins.pathExists (path + "/${name}/default.nix")
    ) (builtins.readDir path);

  nixFiles =
    path:
    lib.filterAttrs (name: kind: kind == "regular" && lib.hasSuffix ".nix" name) (
      builtins.readDir path
    );
}
