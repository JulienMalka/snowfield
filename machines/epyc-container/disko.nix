{
  devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-HGST_HTE721010A9E630_JR10034M34EVTK";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "512M";
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
            root = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "mainpool";
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
            size = "100G";
            pool = "mainpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
          persistent = {
            size = "100G";
            pool = "mainpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persistent";
              mountOptions = [ "defaults" ];
            };
          };

          store = {
            size = "600G";
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
