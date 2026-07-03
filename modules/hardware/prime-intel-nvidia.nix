{ config, lib, pkgs, ... }:
let
  # Placeholders; get overridden by ../../prime.nix if the installer wrote
  # one (same pattern as ../../user.nix). Confirm/edit manually otherwise
  # with: lspci | grep -E 'VGA|3D'
  defaults = { intelBusId = "PCI:0:2:0"; nvidiaBusId = "PCI:1:0:0"; };
  bus = if builtins.pathExists ../../prime.nix
        then defaults // (import ../../prime.nix)
        else defaults;
in {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # gives you `nvidia-offload`
      };
      intelBusId = bus.intelBusId;
      nvidiaBusId = bus.nvidiaBusId;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime ];
  };
}
