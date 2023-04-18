{ pkgs, lib, config, ... }:
{

  sops.secrets.ssh-macintosh-pub = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
    mode = "0644";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-pub;
  };

  sops.secrets.ssh-macintosh-priv = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
    mode = "0600";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-priv;
  };

  luj.hmgr.julien =
    {
      home.stateVersion = "22.11";
      luj.programs.neovim.enable = true;
      luj.programs.ssh-client.enable = true;
      luj.programs.git.enable = true;
      luj.programs.gtk.enable = true;
      luj.programs.alacritty.enable = true;
      luj.programs.hyprland.enable = true;
      luj.programs.waybar.enable = true;
      luj.programs.kitty.enable = true;

      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        font = "Fira Font";
        theme = "DarkBlue";
      };

      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
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
          unstable.firefox
          feh
          meld
          vlc
          nerdfonts
          libreoffice
          font-awesome
          nodejs
          neomutt
          htop
          evince
          mosh
          obsidian
          zotero
          flameshot
          kitty
          networkmanagerapplet
          sops
          coq
          cvc5
          coqPackages.coqide
          (why3.withProvers
            [
              unstable.cvc4
              alt-ergo
              z3
            ])
        ];

      fonts.fontconfig.enable = true;

      home.keyboard = {
        layout = "fr";
      };



    };


}
