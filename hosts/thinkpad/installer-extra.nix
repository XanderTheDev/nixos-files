{ pkgs, lib, ... }: {

  environment.etc."motd".text = lib.mkForce ''
    ╔══════════════════════════════════════════════════════╗
    ║           Welcome to the XDOS Installer             ║
    ╚══════════════════════════════════════════════════════╝

    To install your system, run:

        install-system

    NOTE: This machine has Intel + Nvidia hybrid GPU.
    The installer will show your PCI bus IDs at the end.
    Write them down — you will need them to update
    modules/hardware/intel-arc-nvidia.nix afterwards.

    Useful commands:
      lsblk                    - list disks
      lspci | grep -E 'VGA|3D' - show GPU bus IDs
      nmtui                    - connect to Wi-Fi
  '';

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "show-gpu-ids" ''
      echo "GPU PCI Bus IDs (needed for intel-arc-nvidia.nix):"
      echo ""
      lspci | grep -E 'VGA|3D'
      echo ""
      echo "Format for nix config: PCI:bus:device:function"
      echo "e.g. '01:00.0' becomes 'PCI:1:0:0'"
    '')
  ];
}
