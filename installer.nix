{ pkgs, lib, ... }: {

  services.getty.helpLine = lib.mkForce "";

  environment.etc."motd".text = ''
    ╔══════════════════════════════════════════════════════╗
    ║           Welcome to the NixOS Installer             ║
    ╚══════════════════════════════════════════════════════╝

    To install your system, run:

        install-system

    Useful commands:
      lsblk          - list disks
      lspci          - show hardware
      nmtui          - connect to Wi-Fi
  '';

  environment.systemPackages = [
    pkgs.disko
    pkgs.util-linux
    pkgs.pciutils
    pkgs.networkmanager
    (pkgs.writeShellScriptBin "install-system" ''
      set -e
      clear
      echo "╔══════════════════════════════════════════════════════╗"
      echo "║             NixOS System Installer                   ║"
      echo "╚══════════════════════════════════════════════════════╝"
      echo ""

      echo "Available disks:"
      lsblk -d -o NAME,SIZE,MODEL | grep -v loop
      echo ""
      read -p "Target disk (e.g. /dev/nvme0n1): " DISK

      echo ""
      echo "WARNING: This will ERASE $DISK entirely."
      read -p "Type 'yes' to confirm: " CONFIRM
      [ "$CONFIRM" = "yes" ] || { echo "Aborted."; exit 1; }

      echo ""
      echo "Partitioning $DISK..."
      sudo disko --mode disko \
        --override-option "disko.devices.disk.main.device=$DISK" \
        /iso/nixos-files/hosts/laptop/disks.nix

      echo ""
      echo "Installing NixOS (from local store, no downloads needed)..."
      sudo nixos-install \
        --flake /iso/nixos-files#laptop \
        --no-root-passwd \
        --cores 0

      echo ""
      read -sp "Set password for xander: " PASSWORD
      echo ""
      sudo nixos-enter --root /mnt -- bash -c "echo 'xander:$PASSWORD' | chpasswd"

      echo ""
      echo "╔══════════════════════════════════════════════════════╗"
      echo "║                  Install complete!                   ║"
      echo "╚══════════════════════════════════════════════════════╝"
      echo ""
      echo "Run 'reboot' when ready."
    '')
  ];
}
