{ pkgs, ... }:
{
  luj.hmgr.julien = {

    luj.emails.enable = true;
    luj.programs.fish.enable = true;
    systemd.user.startServices = "sd-switch";

    home.stateVersion = "23.11";
    home.packages = [ pkgs.muchsync ];
  };
}
