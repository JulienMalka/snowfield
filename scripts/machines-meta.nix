# Lightweight metadata for all managed NixOS machines.
# Evaluated locally by the snowfield CLI to get SSH targets and channel info.
#
# Usage: nix-instantiate --eval --strict --json scripts/machines-meta.nix
let
  top = import ../.;
  inherit (top) lib;
  inherit (top) inputs;
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  branchOf = name: lock.nodes.${lock.nodes.${lock.root}.inputs.${name}}.original.ref;

  managedMachines = lib.filterAttrs (_: v: v ? nixpkgs_version) lib.snowfield;

  resolveChannel =
    meta:
    let
      metaPath = toString meta.nixpkgs_version;
      stablePath = toString inputs.nixpkgs;
      unstablePath = toString inputs.unstable;
    in
    if metaPath == stablePath then
      "stable"
    else if metaPath == unstablePath then
      "unstable"
    else
      "unknown";

  branchForChannel =
    ch:
    if ch == "stable" then
      branchOf "nixpkgs"
    else if ch == "unstable" then
      branchOf "unstable"
    else
      "unknown";

  resolveHost =
    meta:
    if meta.ips ? vpn then
      meta.ips.vpn.ipv4
    else if
      meta.ips ? public
      && meta.ips.public ? ipv4
      && meta.ips.public.ipv4 != "127.0.0.1"
      && !(lib.hasPrefix "192.168." meta.ips.public.ipv4)
    then
      meta.ips.public.ipv4
    else if meta.ips ? public && meta.ips.public ? ipv6 then
      meta.ips.public.ipv6
    else
      null;

in
lib.mapAttrs (
  _name: meta:
  let
    ch = resolveChannel meta;
  in
  {
    channel = ch;
    branch = branchForChannel ch;
    ssh = {
      host = resolveHost meta;
      port = meta.sshPort;
    };
  }
) managedMachines
