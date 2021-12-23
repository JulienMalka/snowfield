{ config, pkgs, lib, ... }:
{

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
