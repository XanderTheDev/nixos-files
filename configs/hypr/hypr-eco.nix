{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

home.file = {
    
	# Setting up the idle daemon
	".config/hypr/hypridle.conf".text = ''
	general {
    		after_sleep_cmd = hyprctl dispatch dpms on
    		lock_cmd = pidof || hyprlock
    		before_sleep_cmd = loginctl lock-session
	}	

	listener {
    		timeout = 150 # 2.5 minutes
    		on-timeout = brightnessctl -s set 10
    		on-resume = brightnessctl -r
	}

	listener {
    		timeout = 300 # 5 minutes
    		on-timeout = pidof || hyprlock
	}

	listener {
    		timeout = 330 # 5.5 minutes
    		on-timeout = hyprctl dispatch dpms off
    		on-resume = hyprctl dispatch dpms on && brightnessctl -r
	}

	listener {
    		timeout = 900 # 10 minutes
    		on-timeout = [ "$(cat /sys/class/power_supply/AC0/online)" -eq 0 ] && systemctl suspend
	}
    '';
    # Setting the nerdfont list for the nerdfont picker program
    ".config/nerdfontlist.txt".source = ../../lists/nerdfont.txt;
    ".config/nerdfont-icon-picker".text = ''
	#!/usr/bin/env bash

	# File with icon list: glyph + description
	ICON_FILE="$HOME/.config/nerdfontlist.txt"

	# Pick using wofi
	selection=$(cat "$ICON_FILE" | wofi --dmenu --prompt "Nerd Font Icon:")

	# Get the first column (the glyph)
	glyph=$(echo "$selection" | awk '{print $1}')

	# Copy to clipboard
	echo -n "$glyph" | wl-copy

	# Optional notification
	notify-send "Copied glyph: $glyph"
    '';
    ".config/nerdfont-icon-picker".executable = true;
  };

  # Setting up Hyprland and importing the hyprland config
  wayland.windowManager.hyprland = {
	enable = true;
	systemd.enable = true;
	xwayland.enable = true;
	
	extraConfig = "
		source = ${./hyprland.conf}
	";

  };
	
  # Importing the hyprlock config
  programs.hyprlock = {
	enable = true;
	extraConfig = "
		source = ${./hyprlock.conf}
	";
  };

}
