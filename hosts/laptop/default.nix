{ inputs, config, lib, pkgs, ... }:
{
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

  systemd.services.fix-vivobook-mic = {
    description = "Force correct ALC256 internal mic source";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.alsa-utils}/bin/amixer -c 1 cset numid=6 2 || true
      ${pkgs.alsa-utils}/bin/amixer -c 1 cset numid=11 2 || true
      ${pkgs.alsa-utils}/bin/amixer -c 1 cset numid=8 on || true
    '';
  };

  systemd.timers.fix-vivobook-mic = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3s";
      OnUnitActiveSec = "3s";
    };
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = { governor = "powersave"; turbo = "auto"; };
      charger = { governor = "performance"; turbo = "auto"; };
    };
  };
}
