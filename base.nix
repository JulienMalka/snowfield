{ config, pkgs, sops-nix, ... }:

{

  imports = [
    ./users/default.nix
    ./users/julien.nix
  ];

  luj.nix.enable = true;
  luj.secrets.enable = true;
  luj.ssh-server.enable = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };


  luj.programs.mosh.enable = true;
  programs.gnupg.agent.enable = true;

  networking.firewall.enable = true;
  environment.systemPackages = with pkgs; [
    wget
    rxvt_unicode
    xorg.xbacklight
    neovim
  ];

  environment.variables.EDITOR = "nvim";


}
