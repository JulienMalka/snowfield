{ pkgs, lib, config, inputs, ... }:
{

  luj.hmgr.julien =
    {
      home.stateVersion = "23.05";
      luj.programs.neovim.enable = true;
      luj.programs.ssh-client.enable = true;
      luj.programs.git.enable = true;
      luj.programs.gtk.enable = true;
      luj.programs.kitty.enable = true;
      luj.programs.emacs.enable = false;
      luj.programs.zsh.enable = true;
      luj.programs.hyprland.enable = true;
      luj.programs.dunst.enable = true;
      luj.emails.enable = true;

      luj.programs.waybar = {
        enable = true;
        interfaceName = "";
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


      home.packages = with pkgs;
        [
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
          unstable.signal-desktop
          font-awesome
          nodejs
          neomutt
          htop
          evince
          mosh
          zotero
          flameshot
          albert
          kitty
          networkmanagerapplet
          element-desktop
          xdg-utils
          onagre
          sops
          step-cli
          scli
          spotify-tui
          jftui
          texlive.combined.scheme-full
        ];

      fonts.fontconfig.enable = true;

      programs.firefox = {
        enable = true;
        package = pkgs.firefox-esr;
      };

      home.keyboard = {
        layout = "fr";
      };
    };


}
