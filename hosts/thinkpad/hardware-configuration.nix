# TEMPORARY placeholder — the ThinkPad isn't owned yet, so there are no real
# disk UUIDs to commit. This intentionally does NOT set fileSystems; instead
# disks.nix has disko.enableConfig = true so disko derives fileSystems from
# the partition layout itself (same approach as hosts/generic).
#
# Once the machine is actually installed:
#   1. Boot it, run: nixos-generate-config --root /mnt
#   2. Replace this file with the real generated hardware-configuration.nix
#   3. Set disko.enableConfig = false in ./disks.nix (like hosts/laptop)
#   4. Fill in the real Nvidia/Intel PCI bus IDs (prime.nix, or run the
#      installer again so it detects them)
{ lib, ... }: {
  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "thunderbolt"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
