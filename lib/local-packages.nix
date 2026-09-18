{ pkgs, unstable }:
let
  discovery = import ./discovery.nix { inherit (pkgs) lib; };
  packages = builtins.mapAttrs (name: _: pkgs.callPackage (../packages + "/${name}") { }) (
    discovery.directories ../packages
  );
in
packages
// {
  new-api = unstable.callPackage ../packages/new-api { };
}
