{ pkgs, ... }:
{

  luj.hmgr.julien =
    {
      home.stateVersion = "22.11";
      luj.programs.neovim.enable = true;
      luj.programs.ssh-client.enable = true;
      luj.programs.git.enable = true;
      luj.programs.gtk.enable = true;
      luj.programs.alacritty.enable = true;
      luj.programs.waybar.enable = true;
      luj.programs.waybar.interfaceName = "wlp3s0";
      luj.programs.kitty.enable = true;
      luj.programs.dunst.enable = true;
      luj.emails.enable = true;
      luj.programs.firefox.enable = true;
      luj.programs.sway = {
        enable = true;
        modifier = "Mod4";
        background = ./wallpaper.jpg;
      };

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
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 15;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      home.packages = with pkgs;
        [
          du-dust
          kitty
          jq
          lazygit
          fira-code
          feh
          meld
          emacs29-pgtk
          vlc
          jftui
          nerdfonts
          libreoffice
          font-awesome
          cantarell-fonts
          roboto
          nodejs
          neomutt
          htop
          evince
          mosh
          zotero
          flameshot
          kitty
          networkmanagerapplet
          xdg-utils
          sops
          step-cli
          gh
          gh-dash
          cvc5
          signal-desktop
          scli
          texlive.combined.scheme-full
        ];

      fonts.fontconfig.enable = true;

      home.keyboard = {
        layout = "fr";
      };

    };


}
