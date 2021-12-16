{ config, pkgs, lib, ... }:
let
  cfg = config.luj.hmgr;
in
with lib;
{
  options.luj.hmgr = mkOption {
    type = with types; attrsOf anything;
  };


  config = {
    home-manager.users =
      lib.mapAttrs
        (name: value:
          {
            imports = [ ../../home-manager-modules/git/default.nix ../../home-manager-modules/neovim/default.nix ];
            home.username = "${name}";
            home.homeDirectory = "/home/${name}";
            home.stateVersion = "21.11";
          } // value)
        cfg;
  };
}  







