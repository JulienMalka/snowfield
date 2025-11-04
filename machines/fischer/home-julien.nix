{ pkgs, lib, ... }:
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
    luj.programs.hyprland.enable = true;

    luj.emails.enable = true;

    services.mbsync.postExec = lib.mkForce null;

    services.mbsync.enable = lib.mkForce false;
    programs.mbsync.enable = lib.mkForce false;
    programs.notmuch.hooks.postNew = lib.mkForce "";

    services.muchsync.remotes."gustave" = {
      frequency = "minutely";
      local.checkForModifiedFiles = true;
      remote.checkForModifiedFiles = true;
      remote.host = "gustave";
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 15;
    };

    services.screen-locker = {
      enable = true;
      lockCmd = "XSECURELOCK_PASSWORD_PROMPT=time_hex ${pkgs.xsecurelock}/bin/xsecurelock";
      xautolock.enable = false; # means use xss-lock
      xss-lock.extraOptions = [
        "--notifier=${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"
        "-l" # prevents suspend before locker is started
      ];
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
        vlc
        jftui
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
        kanidm
        yubioath-flutter
        ltex-ls-plus
        powerline-fonts
        drawio
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fonts.fontconfig.enable = true;

    home.keyboard = {
      layout = "fr";
    };
  };
}
