{ lib, pkgs, config, inputs, ... }:

{
  
  # Enable Thunar
  programs.thunar.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # System packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    anki-bin
    bat
    #blueman
    brave
    btop
    cava
    cmatrix
    exiftool
    eza
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
    macchina
    mate.mate-icon-theme-faenza
    neovim
    networkmanagerapplet
    poppler
    python311
    p7zip
    ripgrep
    kdePackages.sddm
    spotify
    swaynotificationcenter
    tor-browser
    trashy
    udiskie
    udisks2
    vim
    w3m
    waybar
    wget
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
