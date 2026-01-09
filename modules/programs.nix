{ lib, pkgs, config, inputs, ... }:

{

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Enable Thunar
  programs.thunar.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  
  services.flatpak.enable = true;

  # Enable virtualisation for distrobox
  virtualisation.podman = {
  	enable = true;
  	dockerCompat = true;
  };
    
  # System packages
  environment.systemPackages = with pkgs; [
    linux-firmware
    adwaita-icon-theme
    mesa
    alsa-utils
    anki-bin
    bat
    blender
    #blueman
    brave
    btop
    calibre
    cava
    cmatrix
    distrobox
    espeak-ng
    exiftool
    eza
    fastfetch
    fd
    ffmpegthumbnailer
    foot
    fzf
    gcc
    git
    gitui
    gparted
    gtk3
    hypridle
    hyprshot
    inetutils
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.hyprlock
    imagemagick
    jq
    killall
    librewolf
    libnotify
    libva
    libva-utils
    libvdpau
    libvdpau-va-gl
    lutris
    lxqt.pavucontrol-qt
    macchina
    marksman
    mate.mate-icon-theme-faenza
    networkmanagerapplet
    nixd
    nmap
    ollama
    onlyoffice-desktopeditors
    pamixer
    poppler
    protonvpn-gui
    pyright
    python311
    p7zip
    ripgrep
    rust-analyzer
    rustup
    kdePackages.sddm
    spotify
    swaynotificationcenter
    thunderbird
    tor-browser
    transmission_4-gtk
    trashy
    udiskie
    udisks2
    vim
    vlc
    w3m
    waybar
    wget
    wireguard-tools
    wl-clipboard
    wlogout
    wofi
    xdg-desktop-portal-hyprland
    yazi
    zsh
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
  ];
 
}
