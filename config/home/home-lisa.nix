{ config, pkgs, lib, ... }:

let 
   nvimsettings = import ./nvim/nvim.nix;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
	rnix-lsp
	sumneko-lua-language-server
  ];



 nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];




programs.neovim = nvimsettings pkgs;
programs.fish.functions = {
  fish_greeting = {
      description = "Greeting to show when starting a fish shell";
      body = "";
    };
};

programs.git = {
  enable = true;
  userName = "Julien Malka";
  userEmail = "julien.malka@me.com";
};

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "julien";
  home.homeDirectory = "/home/julien";

  home.stateVersion = "21.11";

}
