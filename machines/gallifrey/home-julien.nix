{ pkgs, lib, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "24.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.kitty.enable = true;
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

    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
    };

    dconf.settings = {
      "org/gnome/shell" = {
        welcome-dialog-last-shown-version = "999"; # prevent popup until gnome version 999 :)
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-studio-plugins.obs-vkcapture ];
    };

    programs.mu.enable = true;

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-igc;
      extraPackages = epkgs: [
        epkgs.mu4e
      ];
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
        gh
        ouch
        spotify
        nautilus
        pika-backup
        mpv
        zotero
        emacsPackages.jinx
        hunspellDicts.en_US
        hunspellDicts.fr-moderne
        forge-sparks
        citations
        blanket
        fragments
        metadata-cleaner
        gnome-obfuscate
        warp
        tuba
        resources
        notify-client
        emacs-lsp-booster
        pyright
        nixfmt-rfc-style
        slack
        haskell-language-server
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fonts.fontconfig.enable = true;

    systemd.user.tmpfiles.rules = [
      "L /home/julien/.emacs.d - - - - /home/julien/dev/emacs-config"
    ];

    home.persistence."/persistent/home/julien" = {
      files = [
        ".config/gnome-initial-setup-done"
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
        ".local/share/com.ranfdev.Notify.sqlite"
      ];
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        "devold"
        ".config/cosmic"
        ".local/share/direnv"
        ".local/state/cosmic-comp"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/pika-backup"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        ".cache/mu"
        "Maildir"
      ];
      allowOther = true;
    };

    home.keyboard = {
      layout = "fr";
    };
  };
}
