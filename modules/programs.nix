{ lib, pkgs, config, inputs, ... }:
{
  
  # Allow unfree programs
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

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
    android-tools
    anki-bin
    bat
    blender
    #blueman
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
    firefox
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
    mate-icon-theme-faenza
    networkmanagerapplet
    nixd
    nmap
    ollama
    onlyoffice-desktopeditors
    openvpn3
    pamixer
    poppler
    prismlauncher
    proton-vpn
    pyright
    python3
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
