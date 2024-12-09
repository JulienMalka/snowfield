{ pkgs, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "22.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.gtk.enable = true;
    luj.programs.waybar.enable = true;
    luj.programs.waybar.interfaceName = "enp0s13f0u1u4u4";
    luj.programs.kitty.enable = true;
    luj.programs.fish.enable = true;
    luj.programs.dunst.enable = true;
    luj.programs.firefox.enable = true;
    luj.emails.enable = true;
    luj.programs.hyprland.enable = true;

    programs.emacs = {
      enable = true;
      package = pkgs.emacs30;
      extraPackages = epkgs: [
        epkgs.mu4e
      ];
    };

    programs.mu.enable = true;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "Fira Font";
      theme = "DarkBlue";
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 15;
    };

    home.packages = with pkgs; [
      du-dust
      kitty
      jq
      lazygit
      fira-code
      feh
      meld
      vlc
      jftui
      nerdfonts
      cantarell-fonts
      libreoffice
      font-awesome
      nodejs
      htop
      evince
      mosh
      zotero
      flameshot
      networkmanagerapplet
      xdg-utils
      step-cli
      gh
      gh-dash
      signal-desktop
      scli
      emacsPackages.jinx
      hunspellDicts.en_US
      hunspellDicts.fr-moderne
      texlive.combined.scheme-full
      hledger
      emacs-lsp-booster
      pkgs.stable.pyright
      unstable.nixd
      unstable.nixfmt-rfc-style
    ];

    fonts.fontconfig.enable = true;

    home.keyboard = {
      layout = "fr";
    };
  };
}
