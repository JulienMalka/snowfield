{ config, lib, ... }:
let
  cfg = config.luj.ssh-server;
in
with lib;
{
  options.luj.ssh-server = {
    enable = mkEnableOption "Accept ssh connections";
  };

  config = mkIf cfg.enable
    {
      services.openssh = {
        enable = true;
        ports = [ 45 ];
        settings.PasswordAuthentication = false;
        settings.PermitRootLogin = "yes";
        openFirewall = true;
      };
    };
}
