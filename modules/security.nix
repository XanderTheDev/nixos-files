{ config, pkgs, inputs, lib, ... }:

{
        security.pki.certificateFiles = [ ../caddy-root.crt ];
}
