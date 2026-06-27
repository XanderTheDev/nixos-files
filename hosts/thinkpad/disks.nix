{ lib, ... }: {
  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/nvme1n1"; # second SSD, confirm at install time
      content = {
        type = "gpt";
        partitions = {
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
            size = "16G"; # more RAM so more swap
            content = { type = "swap"; };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
