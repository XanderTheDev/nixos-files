{ pkgs, host, lib, ... }: {

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

  # Print MOTD on shell login since autologin skips it
  environment.etc."profile.d/motd.sh".text = ''
    cat /etc/motd
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
      echo "Partitioning and installing NixOS..."
      sudo disko-install \
        --flake /iso/nixos-files#${host} \
        --disk main "$DISK"

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

  isoImage.contents = [{
    source = pkgs.runCommand "nixos-files" {} ''
      cp -r ${./.} $out
    '';
    target = "/nixos-files";
  }];
}
