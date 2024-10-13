{ pkgs, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "24.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.kitty.enable = true;
    luj.programs.emacs.enable = false;
    luj.programs.fish.enable = true;
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
      package = pkgs.adwaita-icon-theme;
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
      inochi-creator
      inochi-session
      chromium
      gh
      ouch
      spotify
      gnome.nautilus
      pika-backup
      mpv
    ];

    fonts.fontconfig.enable = true;

    home.persistence."/persistent/home/julien" = {
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        "dev"
        ".mozilla"
        ".config/cosmic"
        ".local/share/direnv"
        ".local/state/cosmic-comp"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".step"
        ".emacs.d"
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
