inputs: lib:
with lib;
let
  modules = [
    {
      options.machines = mkOption {
        description = "My machines";
        type =
          with types;
          attrsOf (
            submodule (
              { name, ... }:
              {
                freeformType = attrs;
                options = {
                  hostname = mkOption {
                    description = "The machine's hostname";
                    type = str;
                    default = name;
                    readOnly = true;
                  };
                  sshPort = mkOption {
                    description = "The port for the ssh server of the machine";
                    type = int;
                    default = 45;
                  };
                  sshUser = mkOption {
                    description = "The user for ssh connection to the machine";
                    default = "julien";
                  };
                };
              }
            )
          );
        default = { };
      };

      config = rec {
        _module.freeformType = with types; attrs;

        domain = "julienmalka.me";
        internalDomain = "luj";
        tld = "luj";

        machines = {
          lisa = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "212.129.40.11";
              vpn = "100.100.45.12";
            };
            ipv6 = {
              public = "2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb";
              vpn = "fd7a:115c:a1e0::c";
            };
          };
          akhaten = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.unstable;
            hm_version = inputs.home-manager-unstable;
            ipv4 = {
              public = "163.172.91.82";
              vpn = "100.100.45.33";
            };
          };

          x2100 = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs_patched;
            hm_version = inputs.home-manager-unstable;
            # TODO: Fix colmena deployment
            ipv4.public = "127.0.0.1";
          };
          fischer = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs_patched;
            hm_version = inputs.home-manager-unstable;
            # TODO: Fix colmena deployment
            ipv4.public = "127.0.0.1";
          };
          enigma = {
            inherit tld;
            arch = "aarch64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4.vpn = "100.100.45.21";
          };
          lambda = {
            inherit tld;
            arch = "aarch64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "141.145.197.219";
              vpn = "100.100.45.13";
            };
            ipv6 = {
              public = "2603:c027:c001:89aa:aad9:34b3:f3c9:924f";
              vpn = "fd7a:115c:a1e0::d";
            };
          };

          tower = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "82.67.34.230";
              local = "192.168.0.103";
              vpn = "100.100.45.9";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:8ec7:b5d2:f663:a67a";
              vpn = "fd7a:115c:a1e0::9";
            };
          };

          gustave = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "82.67.34.230";
              local = "192.168.0.90";
              vpn = "100.100.45.24";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:eb2:aaaa::45";
              vpn = "fd7a:115c:a1e0::18";
            };
          };

          core-security = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "82.67.34.230";
              local = "192.168.0.175";
              vpn = "100.100.45.14";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:40f0:8cff:fe31:3e94";
              vpn = "fd7a:115c:a1e0::e";
            };
          };

          core-data = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "82.67.34.230";
              local = "192.168.0.66";
              vpn = "100.100.45.26";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:be24:11ff:fe09:638d";
              vpn = "fd7a:115c:a1e0::1a";
            };
          };

          nuage = {
            inherit tld;
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
            ipv4 = {
              public = "82.67.34.230";
              local = "192.168.0.101";
              vpn = "100.100.45.28";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:95c9:b2e2:e999:1a45";
              vpn = "fd7a:115c:a1e0::1c";
            };
          };

          doma-backups = {
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
            inherit tld;
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
      };
    }
  ];
in
(evalModules { inherit modules; }).config
