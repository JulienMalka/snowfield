{
  devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-PNY_CS2241_4TB_SSD_PNY23362309060100017";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "10G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ ];
                passwordFile = "/tmp/secret.key";
                settings = {
                  # if you want to use the key for interactive login be sure there is no trailing newline
                  # for example use `echo -n "password" > /tmp/secret.key`
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "mainpool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      mainpool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "500G";
            pool = "mainpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
          persistent = {
            size = "1T";
            pool = "mainpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persistent";
              mountOptions = [ "defaults" ];
            };
          };

          store = {
            size = "2T";
            pool = "mainpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
