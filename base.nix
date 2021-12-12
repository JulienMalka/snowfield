{ config, pkgs, ... }:

{

  imports = [ ./users/julien.nix ];
  luj.nix.enable = true;

  time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "fr";
    };

   
    #boot.kernelPackages = pkgs.linuxPackages_latest;

    services.openssh.enable = true;
    programs.mosh.enable = true;


}
