{
  pkgs,
  unstable,
  inputs,
}:
let
  discovery = import ./discovery.nix { inherit (pkgs) lib; };
  # Packages whose source is the flake input of the same name.
  fromInput = [
    "cal-proxy"
    "gh-proxy"
    "tp7-sync"
  ];
  packages = builtins.mapAttrs (
    name: _:
    pkgs.callPackage (../packages + "/${name}") (
      pkgs.lib.optionalAttrs (builtins.elem name fromInput) { src = inputs.${name}; }
    )
  ) (discovery.directories ../packages);
in
packages
// {
  # Prisma's generated types hang during import on Python 3.14.
  litellm-patched = unstable.python313Packages.callPackage ../packages/litellm-patched { };
  # The proxy speaks the Jellyfin 12 API to clients, so it embeds the 12.x web
  # client, which only unstable carries.
  jellyswarrm = pkgs.callPackage ../packages/jellyswarrm { inherit (unstable) jellyfin-web; };
}
