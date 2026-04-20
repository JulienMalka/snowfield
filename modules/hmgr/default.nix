{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.luj.hmgr;
in
with lib;
{
  options.luj.hmgr = mkOption {
    type = with types; attrsOf anything;
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.users = lib.mapAttrs (name: value: {
      imports =
        with builtins;
        (map (x: ../../home-manager-modules + "/${x}/default.nix") (
          attrNames (readDir ../../home-manager-modules)
        ))
        ++ [
          "${inputs.agenix}/modules/age-home.nix"
          value
        ];
      home.username = "${name}";
      home.homeDirectory = lib.mkDefault "/home/${name}";
      home.stateVersion = lib.mkDefault "21.05";
    }) cfg;
  };
}
