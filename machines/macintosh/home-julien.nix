{ config, pkgs, lib, ... }:
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


  luj.hmgr.julien = {
    luj.programs.neovim.enable = true;
    luj.programs.git.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.gtk.enable = true;
    luj.i3.enable = true;
    luj.polybar.enable = true;
    home.packages = with pkgs; [
      unstable.rofi
      unstable.firefox
      feh
      meld
      vlc
      nerdfonts
      font-awesome
      python3
      texlive.combined.scheme-full
      nodejs
      fira-code
      neomutt
      htop
      evince
      brightnessctl
      wireguard
      mosh
      signal-desktop
      flameshot
      ctags
      ungoogled-chromium
      networkmanagerapplet
      sops
    ];


    home.keyboard = {
      layout = "fr";
    };


    fonts.fontconfig.enable = true;

    xsession.enable = true;

    home.stateVersion = "21.11";



  };



}
