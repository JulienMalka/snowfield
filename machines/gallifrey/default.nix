{
  config,
  pkgs,
  inputs,
  profiles,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./syncthing.nix
  ];

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    profiles = with profiles; [ sound ];
    ips.vpn.ipv4 = "100.100.45.35";
  };

  networking.hostName = "gallifrey";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  programs.ssh.knownHosts."epyc.infra.newtype.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
  #services.userborn.enable = true;

  networking.interfaces.eno1.wakeOnLan.enable = true;
  boot.kernelParams = [
    #   # See <https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt> for docs on this
    #   # ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>:<ntp0-ip>
    #   # The server ip refers to the NFS server -- we don't need it.
    #   # "ip=${ipv4.address}::${ipv4.gateway}:${ipv4.netmask}:${hostName}-initrd:${networkInterface}:off:1.1.1.1"
    ## initrd luks_remote_unlock
    "ip=192.168.4.10::192.168.0.1:255.255.248.0:gallifrey-initrd:eno1:none"
  ];

  boot.initrd.kernelModules = [
    "r8169"
  ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      hostKeys = [ "/persistent/initrd/ssh_host_ed25519_key" ];
    };
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "262144";
    }
  ];

  disko = import ./disko.nix;

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    gsp.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.xwayland.enable = true;
  services.postgresql.enable = true;

  programs.dconf.enable = true;

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  security.polkit.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "epyc.infra.newtype.fr";
        maxJobs = 100;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        sshUser = "root";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "benchmark"
          "big-parallel"
        ];
        sshKey = "/home/julien/.ssh/id_ed25519";
        speedFactor = 2;
      }
    ];
  };

  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  environment.systemPackages = with pkgs; [
    tailscale
    brightnessctl
    sbctl
    ddcutil
    xorg.xinit
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tailscale-status
    gnomeExtensions.appindicator
    gnome-tweaks
    pkgs.firefoxpwa
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/lib"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  programs.fuse.userAllowOther = true;

  fileSystems."/persistent".neededForBoot = true;

  system.stateVersion = "24.11";
}
