{ pkgs, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "25.05";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.gtk.enable = true;
    luj.programs.kitty.enable = true;
    luj.programs.dunst.enable = true;
    luj.programs.fish.enable = true;
    luj.programs.firefox.enable = true;
    luj.programs.pass.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 15;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

    home.packages =
      with pkgs;
      [
        du-dust
        kitty
        jq
        lazygit
        fira-code
        feh
        meld
        emacs
        vlc
        jftui
        libreoffice
        font-awesome
        cantarell-fonts
        roboto
        htop
        evince
        mosh
        zotero
        flameshot
        kitty
        networkmanagerapplet
        xdg-utils
        step-cli
        gh
        signal-desktop
        scli
        texlive.combined.scheme-full
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fonts.fontconfig.enable = true;

    home.keyboard = {
      layout = "fr";
    };
  };
}
