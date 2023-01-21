{ pkgs, lib, config, ... }:
{


  luj.hmgr.julien = {
    home.packages = with pkgs; [ unstable.deploy-rs nixpkgs-review nixpkgs-fmt gh sops unstable.nix-eval-jobs nix-bisect htop hydrasect tmux lazygit ];
    home.stateVersion = "22.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
  };
}
