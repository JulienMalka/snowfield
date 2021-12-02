{ config, pkgs, ... }:

{
   nix = {
      autoOptimiseStore = true;
      allowedUsers = [ "julien" ];
      gc = {
         automatic = true;
	 dates = "daily";
      };
      package = pkgs.nixUnstable;
      extraOptions = ''
         experimental-features = nix-command flakes
      '';
   };


  time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "fr";
    };

   users.users.julien = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; 
	home = "/home/julien";
        shell = pkgs.fish;
    };


    services.openssh.enable = true;


}
