# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  
  services.xserver = {
	enable = true;
	xkb = {
		layout = "us";
		variant = "";
		options = "";
	};
  };
  # Enabling sddm
  services.displayManager.sddm.enable = true;
  # Configuring sddm to use wayland
  services.displayManager.sddm.wayland.enable = true;

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

  programs.thunar.enable = true;
  
  virtualisation.virtualbox.guest.enable = true;
  
  # Compatibility
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
  };
  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xander = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # System packages
  environment.systemPackages = with pkgs; [
    bat
    blueman
    brave
    btop
    exiftool
    fd
    ffmpegthumbnailer
    foot
    fzf
    git
    gitui
    gnome.adwaita-icon-theme
    gparted
    gtk3
    imagemagick
    jq
    killall
    librewolf
    mate.mate-icon-theme-faenza
    neofetch
    neovim
    networkmanagerapplet
    poppler
    python311
    p7zip
    ripgrep
    sddm
    terminator
    vim
    w3m
    waybar
    wget
    wl-clipboard
    wlogout
    wofi
    xdg-desktop-portal-hyprland
    yazi
    zoxide
  ];

  stylix.enable = true;
  stylix.image = ./wallpapers/lake-sunrise.jpg;
  stylix.polarity = "dark";
  services.upower.enable = true;
  
  
  #nixpkgs.overlays = [
  #(final: prev:
  #  {
  #    ags = prev.ags.overrideAttrs (old: {
  #      buildInputs = old.buildInputs ++ [ pkgs.libdbusmenu-gtk3 ];
  #    });
  #  }
  #)
  #];

  fonts.packages = with pkgs; [
	nerdfonts
        font-awesome
	noto-fonts
	cantarell-fonts
	roboto
	fira
	dejavu_fonts
	liberation_ttf
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable openGL
  hardware.opengl.enable = true;

  # Enabling flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # DO NOT CHANGE! It's the first version of the OS. You need it so you can rollback correctly
  system.stateVersion = "24.05"; # Did you read the comment?
  
}

