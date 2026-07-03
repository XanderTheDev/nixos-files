{ pkgs, host, lib, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  # PyGObject needs these typelibs on GI_TYPELIB_PATH to find Gtk 4 at all —
  # nothing wires this up automatically for plain environment.systemPackages.
  # (matches the dev shell's shellHook)
  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.gtk4 pkgs.libadwaita pkgs.gdk-pixbuf pkgs.pango pkgs.glib
    pkgs.graphene pkgs.gobject-introspection
  ];

  # Real settings from configs/waybar/waybar-settings.nix, trimmed to modules
  # that don't need Hyprland's IPC (hyprland/workspaces, hyprland/window,
  # wlr/taskbar) or apps we don't ship on the ISO (wlogout, tray, pulseaudio).
  waybarBaseSettings = import ./configs/waybar/waybar-settings.nix;
  waybarInstallerSettings = waybarBaseSettings // {
    height = 32;
    modules-left = [ "clock" ];
    modules-right = [ "cpu" "temperature" "battery" "network" ];
  };
  waybarConfig = pkgs.writeText "installer-waybar-config.json" (builtins.toJSON waybarInstallerSettings);

  # Simplified, static port of configs/waybar/waybar.nix's style: same
  # Catppuccin Mocha pill look, but with literal hex values instead of
  # config.stylix.base16Scheme.* — stylix/home-manager isn't wired up for
  # the ISO's xdos user, so those interpolations aren't available here.
  waybarStyle = pkgs.writeText "installer-waybar-style.css" ''
    * {
      font-family: "FiraCode Nerd Font", "Font Awesome", monospace;
      font-size: 14px;
    }
    window#waybar { background-color: transparent; color: #cdd6f4; }
    #clock, #cpu, #temperature, #battery, #network {
      background-color: #1e1e2e;
      color: #cdd6f4;
      border: 2px solid #89b4fa;
      border-radius: 23px;
      margin-top: 5px; margin-bottom: 5px;
      padding: 0 14px;
    }
    #battery.critical:not(.charging) { background-color: #f9e2af; color: #1e1e2e; }
    #temperature.critical { background-color: #f38ba8; color: #1e1e2e; }
  '';

  # No Hyprland here on purpose: the shipped Hyprland config opens hyprlock
  # on start, and live-boot GPU state (proprietary Nvidia not installed yet,
  # unknown hardware for iso-generic) is less predictable than on an
  # installed system. labwc is a plain, minimal wlroots compositor — same
  # wlr-layer-shell protocol waybar already needs, no lock screen, no
  # Hyprland-specific IPC to go wrong.
  startGraphicalInstaller = pkgs.writeShellScript "start-graphical-installer" ''
    set -e
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    mkdir -p "$XDG_RUNTIME_DIR"
    export GI_TYPELIB_PATH="${giTypelibPath}"

    dbus-run-session labwc &
    COMPOSITOR_PID=$!

    for i in $(seq 1 50); do
      [ -S "$XDG_RUNTIME_DIR/wayland-1" ] && break
      sleep 0.2
    done

    waybar -c ${waybarConfig} -s ${waybarStyle} &
    WAYBAR_PID=$!

    ${pythonEnv}/bin/python3 /iso/nixos-files/installer.py

    kill "$WAYBAR_PID" "$COMPOSITOR_PID" 2>/dev/null || true
  '';
in {
  services.getty.helpLine = lib.mkForce "";

  environment.etc."motd".text = ''
    ╔══════════════════════════════════════════════════════╗
    ║           Welcome to the XDOS Installer               ║
    ╚══════════════════════════════════════════════════════╝
    Starting the graphical installer...
    Ctrl+Alt+F2 for a terminal (install-system for a manual/text install,
    lsblk/lspci/dmidecode for hardware info, nmtui for Wi-Fi).
  '';

  environment.loginShellInit = ''
    cat /etc/motd
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec ${startGraphicalInstaller}
    fi
  '';

  environment.systemPackages = [
    pkgs.disko
    pkgs.util-linux
    pkgs.pciutils
    pkgs.dmidecode
    pkgs.networkmanager
    pythonEnv
    pkgs.labwc
    pkgs.waybar
    pkgs.foot
    pkgs.gtk4
    pkgs.libadwaita
    pkgs.gsettings-desktop-schemas
    pkgs.adwaita-icon-theme
    (pkgs.writeShellScriptBin "install-system" ''
      set -e
      clear
      echo "╔══════════════════════════════════════════════════════╗"
      echo "║             XDOS System Installer (manual/text)     ║"
      echo "╚══════════════════════════════════════════════════════╝"
      echo ""
      echo "Available disks:"
      lsblk -d -o NAME,SIZE,MODEL | grep -v loop
      echo ""
      read -p "Target disk (e.g. /dev/nvme0n1): " DISK
      read -p "Flake target (e.g. laptop, thinkpad, laptop-amd, desktop-intel-nvidia): " PROFILE
      echo ""
      echo "WARNING: This will ERASE $DISK entirely."
      read -p "Type 'yes' to confirm: " CONFIRM
      [ "$CONFIRM" = "yes" ] || { echo "Aborted."; exit 1; }
      echo ""
      echo "Partitioning and installing NixOS ($PROFILE)..."
      sudo disko-install \
        --flake "/iso/nixos-files#$PROFILE" \
        --disk main "$DISK"
      echo ""
      read -p "Username to create: " NEWUSER
      echo "{ username = \"$NEWUSER\"; }" | sudo tee /mnt/etc/nixos-user-hint.nix >/dev/null || true
      read -sp "Set password for $NEWUSER: " PASSWORD
      echo ""
      sudo nixos-enter --root /mnt -- bash -c "echo '$NEWUSER:$PASSWORD' | chpasswd"
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

  system.nixos.distroName = "XDOS";
  system.nixos.distroId = "xdos";
  system.nixos.label = "XDOS-26.05";
}
