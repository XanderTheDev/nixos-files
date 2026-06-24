{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-system" ''
      set -e
      echo "╔══════════════════════════════╗"
      echo "║    NixOS System Installer    ║"
      echo "╚══════════════════════════════╝"
      echo ""
      echo "Available disks:"
      lsblk -d -o NAME,SIZE,MODEL | grep -v loop
      echo ""
      read -p "Target disk (e.g. /dev/nvme0n1): " DISK
      echo ""
      echo "WARNING: This will ERASE $DISK entirely."
      read -p "Type 'yes' to confirm: " CONFIRM
      [ "$CONFIRM" = "yes" ] || { echo "Aborted."; exit 1; }

      echo "Partitioning $DISK..."
      sudo disko --mode disko \
        --override-option "disko.devices.disk.main.device=$DISK" \
        /iso/nixos-files/hosts/laptop/disks.nix

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
      echo "Done! Run 'reboot' to boot into your system."
    '')
  ];

  isoImage.contents = [{
    source = ./.;
    target = "/iso/nixos-files";
  }];
}
