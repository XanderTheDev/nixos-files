{ lib, ... }: {
  # Unlike the laptop/thinkpad hosts (which have a committed
  # hardware-configuration.nix and so disable this), generic profiles have no
  # static per-machine file — disko must generate fileSystems/swapDevices
  # itself from the partition layout below.
  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/sda"; # overridden at install time via --disk main <path>
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
            size = "8G";
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
