{ config, pkgs, lib, modulesPath, ... }:
let
  hostName = "newton";
in
{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware.nix
      ./home-julien.nix
      ../../users/julien.nix
      ../../users/default.nix
    ];

  luj = {
    filerun = {
      enable = true;
      subdomain = "cloud";
    };
    paperless = {
      enable = true;
      nginx.enable = true;
      nginx.subdomain = "papers";
    };
    zfs-mails.enable = true;
    zfs-mails.name = hostName;
    zfs-mails.smart.enable = true;
  };

  networking.hostName = hostName;
  networking.hostId = "f7cdfbc9";
  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp2s0f1.useDHCP = true;

  services.fail2ban.enable = true;

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;


 networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.10/24" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";

      peers = [
        {
          allowedIPs = [ "10.100.0.0/24" ];
          publicKey = "hz+h9Oque5h+Y/WzOUnai3e9UfIfDsvtqmQH0xycIzs=";
          endpoint = "212.129.40.11:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
 

  system.stateVersion = "21.05";

}
