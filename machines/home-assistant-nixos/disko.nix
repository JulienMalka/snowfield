{
  devices.disk = {
    emmc = {
      type = "disk";
      device = "/dev/mmcblk0";
      content = {
        type = "table";
        format = "msdos";
        partitions = [
          {
            name = "FIRMWARE";
            part-type = "primary";
            fs-type = "fat32";
            start = "4MiB";
            end = "2GiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
              extraArgs = [
                "-n"
                "FIRMWARE"
              ];
            };
          }
        ];
      };
    };
    nvme = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          swap = {
            size = "8G";
            content.type = "swap";
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "nixos"
              ];
            };
          };
        };
      };
    };
  };
}
