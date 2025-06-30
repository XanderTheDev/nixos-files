{ inputs, lib, config, pkgs, ... }:

{

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Disabling GRUB and SSH (not needed for me)
  boot.loader.grub.enable = false;
  services.openssh.enable = false;

  systemd.extraConfig = ''
  	DefaultTimeoutStartSec=10s
  	DefaultTimeoutStopSec=10s
  	LogLevel=notice
  	DefaultDependencies=yes
  '';
  
  # Setting up Plymouth 
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
  
  # Autologin on greetd to Hyprland
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

}
