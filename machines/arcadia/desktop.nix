{ pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
    displayManager.lightdm.enable = true;
    desktopManager.xterm.enable = true;
    windowManager.session = lib.singleton {
      name = "exwm";
      start = ''
        EXWM=true ${pkgs.emacs}/bin/emacs -l /home/julien/.emacs.d/exwm-config.el
      '';
    };
  };

  security.pam.services.swaylock = { };
  services.gnome.gnome-keyring.enable = true;
}
