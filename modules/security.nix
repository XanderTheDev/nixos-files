{ config, pkgs, inputs, lib, ... }:

{
        security.pki.certificateFiles = [ import ./caddy-root.crt ];
}
