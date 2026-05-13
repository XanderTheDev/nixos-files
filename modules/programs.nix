{ lib, pkgs, config, inputs, ... }:
{
  
  # Allow unfree programs
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Enable Thunar
  programs.thunar.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  virtualisation.docker.enable = true;

  services.flatpak.enable = true;

  # Enable virtualisation for distrobox
  virtualisation.podman = {
  	enable = true;
  	dockerCompat = false;
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
    inputs.brave-origin-src.legacyPackages.${pkgs.system}.brave-origin
    btop
    calibre
    cava
    chafa
    cmatrix
    distrobox
    duckdb
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
    mangohud
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
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.winboat
    wineWow64Packages.stable
    wireguard-tools
    wl-clipboard
    wlogout
    wofi
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    yazi
    zsh
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
  ];
 
}
