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
    home-manager.users = lib.mapAttrs (
      name: value:
      {
        imports =
          with builtins;
          (map (x: ../../home-manager-modules + "/${x}/default.nix") (
            attrNames (readDir ../../home-manager-modules)
          ))
          ++ [
            "${inputs.agenix}/modules/age-home.nix"
          ];
        home.username = "${name}";
        home.homeDirectory = "/home/${name}";
        home.stateVersion = "21.05";
      }
      // value
    ) cfg;
  };
}
