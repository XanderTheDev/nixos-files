{ system, inputs, config, lib, pkgs, ... }:
let
  version = lib.trivial.release;
  codename = lib.trivial.codeName;
  capitalize = s:
    (lib.strings.toUpper (lib.strings.substring 0 1 s))
    + (lib.strings.substring 1 (builtins.stringLength s - 1) s);
  brotherPkgs = import inputs.brother-mfc6490cw-src {
    system = system;
    config.allowUnfree = true;
  };
in {
  networking.networkmanager.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    keep-outputs = true;
    keep-derivations = true;
    eval-cache = true;
  };

  networking.firewall.enable = true;
  networking.firewall.checkReversePath = false;

  time.timeZone = "Europe/Amsterdam";

  environment.etc."os-release".text = lib.mkForce ''
    NAME="XDOS"
    ID=nixos
    PRETTY_NAME="XDOS ${version}"
    VERSION="${version}"
    VERSION_ID="${version}"
  '';

  programs.ssh.startAgent = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "intl";
      options = "";
    };
  };

  # services.minidlna = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     friendly_name = "Xander DLNA";
  #     media_dir = [
  #       "V,/srv/media/Movies"
  #       "A,/srv/media/Music"
  #       "P,/srv/media/Pictures"
  #     ];
  #     inotify = "yes";
  #     notify_interval = 900;
  #     log_level = "info";
  #     wide_links = "yes";
  #   };
  # };

  programs.hyprland.enable = true;
  security.pam.services.hyprlock = {};
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables = {
    EDITOR = "vim";
    WAYLAND_DISPLAY = "wayland-0";
  };

  services.printing = {
    enable = true;
    drivers = [ brotherPkgs.brother-mfc6490cw ];
  };

  hardware.printers.ensurePrinters = [{
    name = "Brother_MFC-6490CW";
    location = "Home";
    deviceUri = "socket://192.168.178.33";
    model = "brmfc6490cw.ppd";
  }];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.udisks2.enable = true;
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.libinput.enable = true;

  users.users.xander = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "docker" "wheel" "networkmanager" "libvirtd" "wireshark" ];
    packages = with pkgs; [];
  };

  programs.zsh.enable = true;
  services.upower.enable = true;
}
