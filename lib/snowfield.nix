{

  # Metadata of machines whose configuration is not handled by this repository

  machines = {

    doma-backups = {
      subdomains = [ "doma-backups.julienmalka.me" ];
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.0.250";
        public.ipv6 = "2a01:e0a:de4:a0e1:6b86:c2c:2141:6702";
      };
    };

    proxmox-nixos-infra = {
      subdomains = [ "proxmox-nixos-update-logs.saumon.network" ];
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.0.177";
        public.ipv6 = "2a01:e0a:de4:a0e1:eb2:caa1::78";
      };
    };

    doma-zulip = {
      subdomains = [ "zulip.julienmalka.me" ];
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.0.187";
        public.ipv6 = "2a01:e0a:de4:a0e1:6830:ddff:fe52:a444";
      };
    };

    pve1 = {
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.1.1";
        vpn.ipv4 = "100.100.45.3";
        public.ipv6 = "2a01:e0a:de4:a0e1:d250:99ff:fefa:b62";
        vpn.ipv6 = "fd7a:115c:a1e0::3";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve2 = {
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.1.2";
        vpn.ipv4 = "100.100.45.15";
        public.ipv6 = "2a01:e0a:de4:a0e1:aaa1:59ff:fec7:1d6";
        vpn.ipv6 = "fd7a:115c:a1e0::f";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve3 = {
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.1.3";
        vpn.ipv4 = "100.100.45.16";
        public.ipv6 = "2a01:e0a:de4:a0e1:aaa1:59ff:fec1:aa10";
        vpn.ipv6 = "fd7a:115c:a1e0::10";
      };
      sshPort = 22;
      sshUser = "root";
    };
    pve4 = {
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.1.4";
        vpn.ipv4 = "100.100.45.17";
        public.ipv6 = "2a01:e0a:de4:a0e1:d250:99ff:fefa:b76";
        vpn.ipv6 = "fd7a:115c:a1e0::11";
      };
      sshPort = 22;
      sshUser = "root";
    };
    saves-paris = {
      subdomains = [ "saves-paris.luj" ];
      ips = {
        public.ipv4 = "82.67.34.230";
        local.ipv4 = "192.168.4.5";
        vpn.ipv4 = "100.100.45.4";
        public.ipv6 = "2a01:e0a:de4:a0e1:3af3:abff:fe6a:1f54";
        vpn.ipv6 = "fd7a:115c:a1e0::4";
      };
      sshPort = 22;
      sshUser = "root";
    };

    saves-lyon = {
      subdomains = [ "saves-lyon.luj" ];
      ips = {
        vpn.ipv4 = "100.100.45.20";
        vpn.ipv6 = "fd7a:115c:a1e0::14";
      };
      sshPort = 22;
      sshUser = "root";
    };
  };
}
