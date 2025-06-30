{ inputs, config, lib, pkgs, ... }:

{

 networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  
  # networking.wireless.iwd = {
#	enable = true;
#	settings.General.EnableNetworkConfiguration = true;
  # };
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
  
  # Setting keyboard 
  services.xserver = {
	enable = true;
	xkb = {
		layout = "us";
		variant = "";
		options = "";
	};
  };

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

  # Standard editor
  environment.variables.EDITOR = "vim";
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enabling security kits
  security.rtkit.enable = true;
  security.polkit.enable = true;
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xander = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  # Enable zsh to be available as shell
  programs.zsh.enable = true;

  # Enable openGL
  hardware.graphics.enable = true;

  # Software for managing power
  services.upower.enable = true;
} 
