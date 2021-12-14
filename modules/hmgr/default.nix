{ config, pkgs, lib, ... }:
let
  cfg = options.luj.hmgr;
in with lib;
{
  options.luj.hmgr = mkOption {
    description = "";
    type = with types; attrsOf (submodule {
      enable = mkEnableOption "enable hmngr for some user";
    });
  };

  config = lib.mapAttrs (name: value: test) cfg; 
}
