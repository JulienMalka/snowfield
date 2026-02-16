{ pkgs, lib, ... }:
{

  luj.hmgr.julien = {
    home.stateVersion = "25.11";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.kitty.enable = true;
    luj.programs.fish.enable = true;
    luj.programs.pass.enable = true;
    luj.emails.enable = true;

    services.mbsync.postExec = lib.mkForce null;

    services.mbsync.enable = lib.mkForce false;
    programs.mbsync.enable = lib.mkForce false;
    programs.notmuch.hooks.postNew = lib.mkForce "";
    programs.notmuch.hooks.preNew = lib.mkForce "";

    services.muchsync.remotes."gustave" = {
      frequency = "minutely";
      local.checkForModifiedFiles = true;
      remote.checkForModifiedFiles = true;
      remote.host = "gustave";
    };

    programs.direnv = {
      enable = true;
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
      package = pkgs.stable.obs-studio;
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs30;
    };

    home.packages =
      with pkgs;
      [
        dust
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
        aporetic
        notmuch
        muchsync
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fonts.fontconfig.enable = true;

    systemd.user.tmpfiles.rules = [
      "L /home/julien/.emacs.d - - - - /home/julien/dev/emacs-config"
    ];

    home.keyboard = {
      layout = "fr";
    };
  };
}
