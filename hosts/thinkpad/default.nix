{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix  # generate this after install
    ./disks.nix
    ../../modules/hardware/intel-cpu.nix
    ../../modules/hardware/intel-arc-nvidia.nix
  ];

  networking.hostName = "thinkpad";

  # Laptop power management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = { governor = "powersave"; turbo = "auto"; };
      charger = { governor = "performance"; turbo = "auto"; };
    };
  };

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Better power management for Intel
  services.thermald.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "zstd";
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    # Intel Arc needs this for proper modesetting
    "i915.force_probe=*"
  ];
}
