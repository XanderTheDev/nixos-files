{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  programs.neovim = {
	enable = true;
	defaultEditor = true;
	plugins = with pkgs.vimPlugins; [
		nvchad-ui
	];
  };

}
