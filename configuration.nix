{ config, lib, pkgs, inputs, ... }: 
let
 dnsConfig =
   if builtins.pathExists ./modules/dns.nix
   then ./modules/dns.nix
   else ./modules/dns-quad9.nix;
in 
{

  imports =
    [
      dnsConfig
      ./hardware-configuration.nix
      ./modules/vm.nix
      ./modules/boot.nix
      ./modules/setup.nix
      ./modules/security.nix
      ./modules/style.nix
      ./modules/programs.nix
    ];

  # Enabling flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # DO NOT CHANGE! It's the first version of the OS. You need it so you can rollback correctly
  system.stateVersion = "24.05"; # Did you read the comment?
  
}

