{ pkgs, ... }:
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
      gh
      ouch
      spotify
      nautilus
      pika-backup
      mpv
      zotero
      emacsPackages.jinx
      hunspellDicts.en_US
      rstudio
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
    ];

    fonts.fontconfig.enable = true;

    home.persistence."/persistent/home/julien" = {
      files = [
        ".config/gnome-initial-setup-done"
        ".config/monitors.xml"
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
        ".local/share/com.ranfdev.Notify.sqlite"
      ];
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        "dev"
        ".mozilla"
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
        ".emacs.d"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
      ];
      allowOther = true;
    };

    home.keyboard = {
      layout = "fr";
    };
  };
}
