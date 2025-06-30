{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  programs.wlogout = {
	enable = true;
	layout = import ./layout.nix;
	style = ''
		* {
			background-image: none;
			box-shadow: none;
		}
		window {
			background-color: rgba(0, 0, 0, 0.75);
		}
		button {
			border-radius: 100;
			border-color: #${config.stylix.base16Scheme.base0D};
			color: #${config.stylix.base16Scheme.base05};
			margin: 2px 10px 10px 2px;
			background-color: #${config.stylix.base16Scheme.base00};
			border-style: solid;
			border-width: 1px;
			background-repeat: no-repeat;
			background-position: center;
			background-size: 25%;
		}
		button:focus, button:active {
			border-radius: 50;
			background-color: #${config.stylix.base16Scheme.base02};
			outline-style: none;
		}
		#lock {
			background-image: image(url("/home/${username}/nixos-files/configs/wlogout/icons/lock.png"));
		}
		#shutdown {
			background-image: image(url("/home/${username}/nixos-files/configs/wlogout/icons/shutdown.png"));
		}
		#reboot {
			background-image: image(url("/home/${username}/nixos-files/configs/wlogout/icons/reboot.png"));
		}
	'';
  };

}
