{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  stylix.targets = {
	waybar.enable = false;
	btop.enable = true;
	fzf.enable = false;
        swaync.enable = true;
        hyprlock.enable = false;
	librewolf = {
		profileNames = [ "default" ];
	};
  };
  
  stylix.fonts = {
	monospace = {
      		package = pkgs.nerd-fonts.fira-code;
      		name = "FiraCode Nerd Font Mono";
    	};
    	sansSerif.name = "FiraCode Nerd Font";
    	serif.name = "FiraCode Nerd Font";
  };

}
