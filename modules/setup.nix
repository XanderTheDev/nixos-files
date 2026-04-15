{ inputs, config, lib, pkgs, ... }:
let
  version = lib.trivial.release;     # "25.11"
  codename = lib.trivial.codeName;   # "xantusia"

  capitalize = s:
    (lib.strings.toUpper (lib.strings.substring 0 1 s))
    + (lib.strings.substring 1 (builtins.stringLength s - 1) s);
in
{
 networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.xserver.videoDrivers = [ "amdgpu" ];

  networking.firewall.enable = true;
  networking.firewall.checkReversePath = false;
  # networking.wireless.iwd = {
#	enable = true;
#	settings.General.EnableNetworkConfiguration = true;
  # };
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  environment.etc."os-release".text = lib.mkForce ''
    NAME="XDOS"
    ID=nixos
    PRETTY_NAME="XDOS ${version}"
    VERSION="${version}"
    VERSION_ID="${version}"
  '';

  programs.ssh.startAgent = true;

  # Setting keyboard 
  services.xserver = {
	enable = true;
	xkb = {
		layout = "us";
		variant = "intl";
		options = "";
	};
  };

# -------------------------
# MiniDLNA / DLNA media server
# -------------------------
# services.minidlna = {
#  enable = true;           # Enable the service
#  openFirewall = true;     # Opens UDP 1900 (SSDP) and TCP 8200 for DLNA discovery
#
#  settings = {
#    # Friendly name shown to clients
#    friendly_name = "Xander DLNA";
#
#    # Media directories
#    media_dir = [
#      "V,/srv/media/Movies"      # Videos
#      "A,/srv/media/Music"       # Audio
#      "P,/srv/media/Pictures"    # Photos
#    ];
#
#    inotify = "yes";       # Automatically detect new files
#    log_level = "info";    # Log info-level messages
#    wide_links = "yes";
#  };
# };

  # Enabling sddm
  # services.displayManager.sddm.enable = true;
  # Configuring sddm to use wayland
  # services.displayManager.sddm.wayland.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  
  console.keyMap = "us";

	
  # Enabling Hyprland
  programs.hyprland = {
  	enable = true;
  };
  
  # Making hyprlock work (security)
  security.pam.services.hyprlock = {}; 

  # Compatibility
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
    EDITOR = "vim";
    WAYLAND_DISPLAY = "wayland-0";  # safe; some apps pick this up
  };

  # Enable CUPS to print documents.
  services.printing = {
        enable = true;
  };
  services.avahi = {
        enable = true;
        nssmdns4 = true;
  };

  # Daemon that implements D-bus interfaces for manipulation of storage devices
  services.udisks2.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
  };

  # Enable bluetooth
  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # Enabling security kits
  security.rtkit.enable = true;
  security.polkit.enable = true;
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xander = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "docker" "wheel" "networkmanager" "libvirtd" "wireshark" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  # Enable zsh to be available as shell
  programs.zsh.enable = true;

  # Enable openGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # Optional, but good for 32-bit apps
    extraPackages = with pkgs; [
    ];
  };

  # Software for managing power
  services.upower.enable = true;
} 
