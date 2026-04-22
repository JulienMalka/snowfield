{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.luj.hmgr;

  inherit (lib) mkOption mapAttrs types;
in
{
  options.luj.hmgr = mkOption {
    description = ''
      home-manager user slots for this host.

      Each entry maps a username to a module (attrset or function) that will be
      included alongside every module in `home-manager-modules/` and the agenix
      home-manager integration. The username is used as `home.username` and
      `home.homeDirectory` (overridable).
    '';
    type = types.attrsOf types.deferredModule;
    default = { };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.users = mapAttrs (name: value: {
      imports = (lib.attrValues (lib.importDir ../../home-manager-modules)) ++ [
        "${inputs.agenix}/modules/age-home.nix"
        value
      ];
      home.username = name;
      home.homeDirectory = lib.mkDefault "/home/${name}";
      home.stateVersion = lib.mkDefault "21.05";
    }) cfg;
  };
}
