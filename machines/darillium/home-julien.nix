{ pkgs, lib, ... }:
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
        slack
        git-absorb
        git-autofixup
        emacsPackages.jinx
        hunspellDicts.en_US
        hunspellDicts.fr-moderne
        emacs
        dust
        kitty
        jq
        lazygit
        fira-code
        feh
        meld
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
        unstable.nixd
        emacs-lsp-booster
        hunspellDicts.en_US
        hunspellDicts.fr-moderne
        rust-analyzer
        cargo
        rustc
        pyright
        unstable.nixfmt-rfc-style
        i3lock
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
