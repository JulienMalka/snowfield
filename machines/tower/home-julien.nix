{ pkgs, lib, config, ... }:
{


  luj.hmgr.julien = {
    home.packages = with pkgs; [ deploy-rs ];
    home.stateVersion = "22.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
  };
}
