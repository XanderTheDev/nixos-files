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
  
  boot.loader.grub.enable = false;
  services.openssh.enable = false;

  systemd.extraConfig = ''
  	DefaultTimeoutStartSec=10s
  	DefaultTimeoutStopSec=10s
  	LogLevel=notice
  	DefaultDependencies=yes
  '';
  
  boot = {

    plymouth = {
      enable = true;
      # theme = lib.mkForce "rings";
      # themePackages = with pkgs; [
        # By default we would install all themes
        # (adi1090x-plymouth-themes.override {
          # selected_themes = [ "rings" ];
        # })
      # ];
      #theme = lib.mkForce "bgrt";
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "video=efifb:off"
      "i915.fastboot=1"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

  };

  services.greetd = {
   enable = true;
   settings = rec {
    initial_session = {
      command = "Hyprland > /dev/null 2>&1 && plymouth quit";
      user = "xander";
    };
    default_session = initial_session;
   };
  };
  
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

  environment.interactiveShellInit = ''
	alias nixrbfl='sudo nixos-rebuild switch --flake .'
  '';

  security.pam.services.hyprlock = {};

  programs.thunar.enable = true;
  
  # Compatibility
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Standard editor
  environment.variables.EDITOR = "vim";
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
  };

  services.blueman.enable = true;

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
    adwaita-icon-theme
    bat
    #blueman
    brave
    btop
    cava
    cmatrix
    exiftool
    fastfetch
    fd
    ffmpegthumbnailer
    foot
    fzf
    git
    gitui
    gparted
    gtk3
    hypridle
    hyprshot
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.hyprlock
    imagemagick
    jq
    killall
    librewolf
    libnotify
    lxqt.pavucontrol-qt
    mate.mate-icon-theme-faenza
    neovim
    networkmanagerapplet
    pfetch
    poppler
    python311
    p7zip
    ripgrep
    kdePackages.sddm
    spotify
    swaynotificationcenter
    vim
    w3m
    waybar
    wget
    wl-clipboard
    wlogout
    wofi
    xdg-desktop-portal-hyprland
    yazi
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
        font-awesome
	noto-fonts
	nerd-fonts.fira-code
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
  hardware.graphics.enable = true;
  
  # Enabling flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # DO NOT CHANGE! It's the first version of the OS. You need it so you can rollback correctly
  system.stateVersion = "24.05"; # Did you read the comment?
  
}

