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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.copySystemConfiguration = false;
  system.stateVersion = "24.05";
}
