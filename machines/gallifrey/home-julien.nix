{ pkgs, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "24.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.kitty.enable = true;
    luj.programs.emacs.enable = false;
    luj.emails.enable = true;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "Fira Font";
      theme = "DarkBlue";
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    home.pointerCursor = {
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 15;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-studio-plugins.obs-vkcapture ];
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
      nerdfonts
      jetbrains-mono
      cantarell-fonts
      unstable.nixd
      libreoffice
      signal-desktop
      font-awesome
      nodejs
      htop
      evince
      mosh
      flameshot
      kitty
      networkmanagerapplet
      element-desktop
      xdg-utils
      step-cli
      scli
      jftui
      texlive.combined.scheme-full
      unstable.inochi-creator
      chromium
      gh
      ouch
    ];

    fonts.fontconfig.enable = true;

    home.persistence."/persistent/home/julien" = {
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        "dev"
        ".mozilla"
      ];
      allowOther = true;
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
    };

    home.keyboard = {
      layout = "fr";
    };
  };
}
