{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ../../modules/hardware/amd-cpu.nix
    ../../modules/hardware/amd-gpu.nix
  ];

  networking.hostName = "nixos";

  boot.kernelPackages = inputs.cachyos-kernel.legacyPackages.${pkgs.system}.linuxPackages-cachyos-latest;
  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "zstd";
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    "video=efifb:off"
  ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = { governor = "powersave"; turbo = "auto"; };
      charger = { governor = "performance"; turbo = "auto"; };
    };
  };
}
