{ config, pkgs, sops-nix, ... }:

{

  imports = [ 
    ./users/default.nix
    ./users/julien.nix 
  ];
  luj.nix.enable = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/julien/.ssh/id_ed25519"];

  time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "fr";
    };

   
    services.openssh.enable = true;
    programs.mosh.enable = true;
    programs.gnupg.agent.enable = true;

}
