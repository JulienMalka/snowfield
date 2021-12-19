{ config, pkgs, lib, ... }:
let
  cfg = config.luj.polybar;
in
with lib; {

  options.luj.polybar = {
    enable = mkEnableOption "Enable polybar";
  };

  config = mkIf cfg.enable {
    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
      };

      script = "polybar -q PolybarTony &";

    };

    xdg.configFile."polybar/config".source = lib.mkForce ./config;

  };
}
