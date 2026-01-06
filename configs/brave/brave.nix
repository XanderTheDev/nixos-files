{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
      (pkgs.writeShellScriptBin "brave" ''
      exec ${pkgs.brave}/bin/brave \
        --no-first-run \
        --disable-extensions \
        --enable-features=VaapiVideoDecoder,VaapiVideoEncoder \
        --use-gl=desktop \
        --ignore-gpu-blocklist \
        --no-default-browser-check \
        "$@"
    '')
  ];

}
