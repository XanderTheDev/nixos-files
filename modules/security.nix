{ config, pkgs, inputs, lib, ... }:

{
        networking.firewall.allowedTCPPorts = [ 53 ];
        networking.firewall.allowedUDPPorts = [ 53 ];
}
