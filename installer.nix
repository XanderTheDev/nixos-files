{ pkgs, lib, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);

  giPackages = with pkgs; [
    gtk4
    libadwaita
    pango.out
    cairo
    glib.out
    gdk-pixbuf
    graphene
    gobject-introspection
    harfbuzz
    at-spi2-core
  ];

  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" giPackages;

  iconPackages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    font-awesome
    networkmanagerapplet
  ];

  xdgDataDirsPath = lib.makeSearchPath "share" iconPackages;

  installerWrapped = pkgs.runCommand "installer-wrapped" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/installer \
      --set GI_TYPELIB_PATH "${giTypelibPath}" \
      --set XDG_DATA_DIRS "${xdgDataDirsPath}" \
      --add-flags "/iso/nixos-files/installer.py"
  '';

  waybarConfig = pkgs.writeText "waybar-config.jsonc" ''
    {
      "layer": "top",
      "position": "top",
      "height": 32,
      "modules-left": ["clock"],
      "modules-right": ["network", "pulseaudio", "tray"],
      "clock": {
        "format": "{:%H:%M}"
      },
      "network": {
        "format-wifi": "  {essid} ({signalStrength}%)",
        "format-ethernet": "  Connected",
        "format-disconnected": "  Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}",
        "on-click": "foot -e nmtui"
      },
      "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "  Muted",
        "format-icons": {
          "default": ["", "", ""]
        },
        "on-click": "foot -e alsamixer"
      },
      "tray": {
        "icon-size": 18,
        "spacing": 8
      }
    }
  '';

  waybarStyle = pkgs.writeText "waybar-style.css" ''
    * {
      font-family: sans-serif;
      font-size: 14px;
    }
    window#waybar {
      background: rgba(20, 20, 20, 0.9);
      color: #ffffff;
    }
    #network, #pulseaudio, #clock, #tray {
      padding: 0 10px;
    }
  '';

  labwcAutostart = pkgs.writeText "labwc-autostart" ''
    until [ -S "$XDG_RUNTIME_DIR/wayland-0" ]; do
      sleep 0.1
    done

    export XDG_DATA_DIRS="${xdgDataDirsPath}:${"$"}{XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

    # Start waybar first so its tray module registers as the
    # StatusNotifierWatcher before nm-applet tries to attach to it.
    ${pkgs.waybar}/bin/waybar -c ${waybarConfig} -s ${waybarStyle} &
    WAYBAR_PID=$!

    sleep 1
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &

    ${installerWrapped}/bin/installer

    kill $WAYBAR_PID 2>/dev/null || true
  '';
in
{
  # ------------------------------------------------------------
  # CORE SESSION
  # ------------------------------------------------------------
  services.xserver.enable = false;
  services.greetd.enable = false;
  services.seatd.enable = true;
  services.getty.autologinUser = "xdos";

  # ------------------------------------------------------------
  # FONTS
  # ------------------------------------------------------------
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    nerd-fonts.fira-code
    cantarell-fonts
    roboto
    fira
    dejavu_fonts
    liberation_ttf
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    corefonts
  ];

  # ------------------------------------------------------------
  # NETWORKING
  # ------------------------------------------------------------
  networking.networkmanager.enable = true;
  users.users.xdos.extraGroups = [ "networkmanager" ];

  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      unset WAYLAND_DISPLAY
      unset XDG_SESSION_TYPE
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=labwc

      # VirtualBox's virtual GPU does not correctly implement the
      # DRM/KMS ioctls wlroots expects (causes "Failed to close buffer
      # handle" / "drmCloseBufferHandle failed: Invalid argument").
      # Force software rendering and disable hardware cursor planes.
      export WLR_RENDERER=pixman
      export WLR_NO_HARDWARE_CURSORS=1

      exec dbus-run-session labwc > /tmp/labwc.log 2>&1
    fi
  '';

  # ------------------------------------------------------------
  # LABWC AUTOSTART
  # ------------------------------------------------------------
  environment.etc."xdg/labwc/autostart".source = labwcAutostart;

  # ------------------------------------------------------------
  # PACKAGES
  # ------------------------------------------------------------
  environment.systemPackages = [
    pkgs.labwc
    pkgs.waybar
    pkgs.foot
    pkgs.networkmanager
    pkgs.networkmanagerapplet
    pkgs.polkit_gnome
    pkgs.alsa-utils
    pkgs.dbus
    pythonEnv
    pkgs.gtk4
    pkgs.libadwaita
    pkgs.gobject-introspection
    pkgs.dmidecode
    pkgs.pciutils
    pkgs.glib
    pkgs.cairo
    pkgs.graphene
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.adwaita-icon-theme
    pkgs.hicolor-icon-theme
    pkgs.disko
    (pkgs.writeShellScriptBin "install-system" ''
      set -e
      clear
      echo "XDOS Installer"
      lsblk -d -o NAME,SIZE,MODEL | grep -v loop
      read -p "Disk: " DISK
      read -p "Profile: " PROFILE
      echo "WILL ERASE $DISK"
      read -p "type yes: " CONFIRM
      [ "$CONFIRM" = "yes" ] || exit 1
      sudo disko-install \
        --flake "/iso/nixos-files#$PROFILE" \
        --disk main "$DISK"
      read -p "Username: " USER
      read -sp "Password: " PASS
      echo ""
      sudo nixos-enter --root /mnt -- bash -c \
        "echo '$USER:$PASS' | chpasswd"
    '')
  ];

  # ------------------------------------------------------------
  # ISO FILES
  # ------------------------------------------------------------
  isoImage.contents = [{
    source = pkgs.runCommand "nixos-files" {} ''
      cp -r --no-preserve=xattr,ownership ${./.} $out
    '';
    target = "/nixos-files";
  }];

  system.nixos.distroName = "XDOS";
  system.nixos.distroId = "xdos";
  system.nixos.label = "XDOS-26.05";
}
