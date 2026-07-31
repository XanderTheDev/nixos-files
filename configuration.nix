{ config, lib, pkgs, inputs, ... }:
let
  dnsConfig =
    if builtins.pathExists ./modules/dns.nix
    then ./modules/dns.nix
    else ./modules/dns-quad9.nix;
in
{
  imports = [
    dnsConfig
    ./modules/vm.nix
    ./modules/boot.nix
    ./modules/setup.nix
    ./modules/security.nix
    ./modules/style.nix
    ./modules/programs.nix
    ./pkgs/elo-mt-usb-driver/module.nix
  ];

  services.elo-mt-usb = {
    enable = true;
    configText = ''
      # Elo touch driver preset configuration
      #FOR VID=03eb PID=8a6e SN=K17R006813 SET INT_NUM=2
    '';
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
  xdg.portal.config = {
    hyprland.default = [ "hyprland" "gtk" ];
    common.default = [ "gtk" ];
  };
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.copySystemConfiguration = false;
  system.stateVersion = "24.05";
}
