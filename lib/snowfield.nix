{

  machines = {

    doma-backups = {
      subdomains = [ "doma-backups.julienmalka.me" ];
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.0.250";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:6b86:c2c:2141:6702";
      };
    };

    proxmox-nixos-infra = {
      subdomains = [ "proxmox-nixos-update-logs.saumon.network" ];
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.0.177";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:eb2:caa1::78";
      };
    };

    doma-zulip = {
      subdomains = [ "zulip.julienmalka.me" ];
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.0.187";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:6830:ddff:fe52:a444";
      };
    };

    pve1 = {
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.1.1";
        vpn = "100.100.45.3";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:d250:99ff:fefa:b62";
        vpn = "fd7a:115c:a1e0::3";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve2 = {
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.1.2";
        vpn = "100.100.45.15";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:aaa1:59ff:fec7:1d6";
        vpn = "fd7a:115c:a1e0::f";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve3 = {
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.1.3";
        vpn = "100.100.45.16";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:aaa1:59ff:fec1:aa10";
        vpn = "fd7a:115c:a1e0::10";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve4 = {
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.1.4";
        vpn = "100.100.45.17";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:d250:99ff:fefa:b76";
        vpn = "fd7a:115c:a1e0::11";
      };
      sshPort = 22;
      sshUser = "root";
    };
    saves-paris = {
      subdomains = [ "saves-paris.luj" ];
      ipv4 = {
        public = "82.67.34.230";
        local = "192.168.4.5";
        vpn = "100.100.45.4";
      };
      ipv6 = {
        public = "2a01:e0a:de4:a0e1:3af3:abff:fe6a:1f54";
        vpn = "fd7a:115c:a1e0::4";
      };
      sshPort = 22;
      sshUser = "root";
    };

    saves-lyon = {
      subdomains = [ "saves-lyon.luj" ];
      ipv4 = {
        vpn = "100.100.45.20";
      };
      ipv6 = {
        vpn = "fd7a:115c:a1e0::14";
      };
      sshPort = 22;
      sshUser = "root";
    };
  };
}
