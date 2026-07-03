{ ... }: {
  # Generic/unknown hardware: no per-machine hardware-configuration.nix
  # exists, so use broadly-safe defaults. disks.nix (disko) provides
  # fileSystems.* — this only covers the rest of what that file normally
  # sets. Loading an unsupported kvm module is harmless (just fails to load).
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = "x86_64-linux";
}
