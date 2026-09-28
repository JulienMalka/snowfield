{ pkgs, unstable }:
let
  discovery = import ./discovery.nix { inherit (pkgs) lib; };
  packages = builtins.mapAttrs (name: _: pkgs.callPackage (../packages + "/${name}") { }) (
    discovery.directories ../packages
  );
in
packages
// {
  # Prisma's generated types hang during import on Python 3.14.
  litellm-patched = unstable.python313Packages.callPackage ../packages/litellm-patched { };
}
