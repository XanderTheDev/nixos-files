{ pkgs, lib, ... }: {

  # Show helpful info on login
  users.users.nixos.openssh.authorizedKeys.keys = [];
  services.getty.helpLine = lib.mkForce "";

  environment.etc."motd".text = ''
    ╔══════════════════════════════════════════════════════╗
    ║           Welcome to the NixOS Installer             ║
    ╚══════════════════════════════════════════════════════╝

    To install your system, run:

        install-system

    If this is a machine with hybrid GPU (Intel + Nvidia), the
    installer will show your PCI bus IDs at the end. Write them
    down — you will need to update modules/hardware/intel-arc-nvidia.nix
    with the correct values after installing.

    Useful commands:
      lsblk                        - list disks
      lspci | grep -E 'VGA|3D'     - show GPU bus IDs
      nmtui                        - connect to Wi-Fi
      install-system               - start the installer
  '';

  environment.systemPackages = [
    pkgs.disko
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
      read -p "Target disk (e.g. /dev/nvme1n1): " DISK

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
      echo "If this machine has hybrid GPU (Intel + Nvidia), here are"
      echo "your PCI bus IDs — write these down:"
      echo ""
      lspci | grep -E 'VGA|3D'
      echo ""
      echo "Update modules/hardware/intel-arc-nvidia.nix with these"
      echo "values before running nixos-rebuild on this machine."
      echo ""
      echo "Run 'reboot' when ready."
    '')
  ];

  isoImage.contents = [{
    source = ./.;
    target = "/iso/nixos-files";
  }];
}
