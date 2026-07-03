{ config, lib, pkgs, ... }:
let
  # Placeholders, overridden by ../../prime.nix if the installer detected and
  # wrote real values (lspci | grep -E 'VGA|3D'). Confirm/edit manually
  # otherwise.
  defaults = { intelBusId = "PCI:0:2:0"; nvidiaBusId = "PCI:1:0:0"; };
  bus = if builtins.pathExists ../../prime.nix
        then defaults // (import ../../prime.nix)
        else defaults;
in {
  # Intel Arc for display
  services.xserver.videoDrivers = [ "nvidia" ]; # nvidia driver manages both with PRIME

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; # lets Nvidia power off when not in use
    open = true; # Blackwell requires open kernel modules
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # RTX Pro 1000 Blackwell is very new, may need beta or latest

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # gives you `nvidia-offload` command
      };
      intelBusId = bus.intelBusId;
      nvidiaBusId = bus.nvidiaBusId;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # Intel Arc video decode
      intel-compute-runtime
    ];
  };

  # Needed for Blackwell open modules
  boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];
}
