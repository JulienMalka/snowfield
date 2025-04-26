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
        du-dust
        kitty
        jq
        lazygit
        fira-code
        feh
        meld
        emacs-igc
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

    home.persistence."/persistent/home/julien" = {
      files = [
        ".config/background"
        ".cert/nm-openvpn/telecom-paris-ca.pem"
      ];
      directories = [
        "Pictures"
        "Documents"
        ".ssh"
        ".mozilla"
        ".local/share/direnv"
        ".local/share/atuin"
        ".local/share/firefoxpwa"
        ".config/Signal"
        ".cache/spotify"
        ".config/spotify"
        ".config/autostart"
        ".config/borg"
        ".config/Element"
        ".step"
        ".gnupg"
        "Zotero"
        ".config/dconf"
        ".local/share/keyrings"
        "Maildir"
      ];
      allowOther = true;
    };

    home.keyboard = {
      layout = "fr";
    };
  };
}
