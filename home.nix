{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {
  # Directory info
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  programs.librewolf = {
    enable = true;
    settings = {
      # Start with a blank page
      "browser.startup.page" = 0;

      # Disable default browser check
      "browser.shell.checkDefaultBrowser" = false;

      # Disable animations for faster UI response
      "toolkit.cosmeticAnimations.enabled" = false;

      # Disable welcome / onboarding page
      "startup.homepage_welcome_url" = "";
      "startup.homepage_welcome_url.additional" = "";

      # Just in case: ensure Pocket is off (LibreWolf usually disables this already)
      "extensions.pocket.enabled" = false;
    };
  };

  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
      (pkgs.writeShellScriptBin "brave" ''
      exec ${pkgs.brave}/bin/brave \
        --no-first-run \
        --disable-extensions \
        --disable-gpu \
        --no-default-browser-check \
        "$@"
    '')
  ];

  imports = [	
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".bashrc".text = ''
    	if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    		macchina -o host -o distribution -o desktop-environment -o shell -o resolution -o uptime
	fi
	
	parse_git_branch () {
    		git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
	}

	function git_prompt () {
    	local OUT=
    	local GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

    	if [[ -n $GIT_ROOT ]]
    		then
        		OUT="  $(basename $GIT_ROOT)"
        		local GIT_BRANCH="$(parse_git_branch)"
        		if [[ "$GIT_BRANCH" == " ((no branch))" ]]
        		then
            			$GIT_BRANCH="($(parse_git_branch))";
        		fi
        	OUT="$OUT $GIT_BRANCH"
    	fi
    	echo $OUT
	}
	
	PS1="\e[\e[31m\]\e[0m\]\[\e[1;41;97m\]  \e[43;31m\]\[\e[0m\]\[\e[1m\e[43;97m\]\u@\h - \t - \d \\e[0m\]\e[33m\]\e[0m\]\n\
\[\e[31m\]\w \[\e[97m\]\$(git_prompt) \[\e[0m\]\[\e[31m\]\$ \[\e[0m\]"

    	alias cp='cp -i'
	alias mv='mv -i'
	alias ls='ls -aFh --color=always'
	alias rm='trash'
	alias mkdir='mkdir -p'
	alias cat='$HOME/.config/cat'
        alias nerdfont-icon-picker='$HOME/.config/nerdfont-icon-picker'
	alias svim='sudo vim'
	alias nrb='sudo nixos-rebuild switch --flake'
	
	alias ..='cd ..'
	alias ...='cd ../..'
	alias ....='cd ../../..'
	alias .....='cd ../../../..'

	cd ()
	{	
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
	}
    '';
    ".config/cat".text = ''
	#!/bin/bash

	read -p "Use bat? [Y/n] " x
	if [[ "$x" =~ ^([nN]|no|NO)$ ]]; then
  		cat "$@"
	else
  		bat "$@"
	fi
    '';
    ".config/cat".executable = true;
    ".config/hypr/hypridle.conf".text = ''
	general {
    		after_sleep_cmd = hyprctl dispatch dpms on
    		lock_cmd = pidof || hyprlock
    		before_sleep_cmd = loginctl lock-session
	}	

	listener {
    		timeout = 150
    		on-timeout = brightnessctl -s set 10
    		on-resume = brightnessctl -r
	}

	listener {
    		timeout = 300
    		on-timeout = pidof || hyprlock
	}

	listener {
    		timeout = 330
    		on-timeout = hyprctl dispatch dpms off
    		on-resume = hyprctl dispatch dpms on && brightnessctl -r
	}

	listener {
    		timeout = 900
    		on-timeout = [ "$(cat /sys/class/power_supply/AC0/online)" -eq 0 ] && systemctl suspend
	}
    '';
    ".config/nerdfontlist.txt".source = lists/nerdfont.txt;
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

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  wayland.windowManager.hyprland = {
	enable = true;
	systemd.enable = true;
	xwayland.enable = true;
	
	extraConfig = "
		source = ${./configs/hypr/hyprland.conf}
	";

  };

  programs.hyprlock = {
	enable = true;
	extraConfig = "
		source = ${./configs/hypr/hyprlock.conf}
	";
  };

  programs.fastfetch = {
	enable = true;

    	settings = {
      display = {
        color = {
          keys = "35";
          output = "95";
        };
        separator = " ➜  ";
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS";
          keyColor = "31";
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "31";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "31";
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "31";
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = "32";
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = "32";
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = "32";
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = "32";
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "32";
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = "33";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7} GHz";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12} GHz";
          key = " ├ 󰢮 ";
          keyColor = "33";
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "33";
        }
        {
          type = "monitor";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "player";
          key = " ├ 󰥠 ";
          keyColor = "33";
        }
        {
          type = "media";
          key = " └ 󰝚 ";
          keyColor = "33";
        }
        "break"
        {
          type = "uptime";
          key = "   Uptime   ";
        }
      ];
    };
  };
   
  programs.waybar = with lib;{
	enable = true;
	package = pkgs.waybar;
	style = concatStrings [ "
	* {
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: NerdFonts, FontAwesome, Roboto, Helvetica, Arial, sans-serif;
    font-size: 13px;
}

window#waybar {
    background-color: transparent;
    color: #ffffff;
    transition-property: background-color;
    transition-duration: 0.5s;
}

window#waybar.hidden {
    opacity: 0.5;
}

/*
window#waybar.empty {
    background-color: transparent;
}
window#waybar.solo {
    background-color: #FFFFFF;
}
*/

window#waybar.termite {
    background-color: rgba(0, 0, 0, 0);
}

window#waybar.chromium {
    background-color: #000000;
    border: none;
}

button {
    /* Use box-shadow instead of border so the text isn't offset */
    box-shadow: inset 0 -3px transparent;
    /* Avoid rounded borders under each button name */
    border: none;
    border-radius: 0;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #BBBBBB;
}

#workspaces button {
    border-radius: 0px;
    padding-right: 4px;
    padding-left: 4px;
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#workspaces button:hover {
    background: #${config.stylix.base16Scheme.base01};
}

#workspaces button.focused {
    background-color: #${config.stylix.base16Scheme.base08};
    box-shadow: inset 0 -3px #${config.stylix.base16Scheme.base02};
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock {
    border-radius: 15px;
    border: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 9px;
    padding-left: 9px;
}
#battery {
    border-radius: 0px 15px 15px 0px;
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 1px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 10px;
    padding-left: 8px;
}
#cpu {
    border-radius: 15px 0px 0px 15px;
    border-left: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 0px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 13px;
    padding-left: 10px;
}
#custom-power_button {
    border-radius: 15px;
    border: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 12.5px;
    padding-left: 9px;
}
#memory {
    border-radius: 3px;
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 4px;
    padding-left: 4px;
}
#disk,
#temperature {
    border-radius: 0px;
    border-left: 0.05rem white solid;
    border-right: 0.05rem white solid;
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 8px;
    padding-left: 8px;
}
#backlight {
    border-radius: 0px 15px 15px 0px;
    border-left: 0.05rem white solid;
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 8px;
    padding-left: 6px;
}
#network {
    border-radius: 15px;
    border: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 14px;
    padding-left: 10px;
}    
#pulseaudio {
    border-radius: 15px 0px 0px 15px;
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    border-left: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 0px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 10px;
    padding-left: 10px;
}
#wireplumber,
#custom-media,
#tray {
    border-radius: 15px;
    border: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 10px;
    padding-left: 10px;
}
#mode,
#idle_inhibitor,
#scratchpad,
#mpd {
    padding: 0 10px;
    color: #ffffff;
}

#window {
    color: #${config.stylix.base16Scheme.base05};
}

#workspaces {
    margin: 0 4px;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#battery {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#battery.charging, #battery.plugged {
    color: #${config.stylix.base16Scheme.base05};
    background-color: #${config.stylix.base16Scheme.base00};
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: #${config.stylix.base16Scheme.base0A};
    color: #${config.stylix.base16Scheme.base05};
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

label:focus {
    background-color: #000000;
}

#cpu {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#custom-power_button {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#memory {
    background-color: #${config.stylix.base16Scheme.base00};
}

#disk {
    background-color: #282a36;
}

#backlight {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#network {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#network.disconnected {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#pulseaudio {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#pulseaudio.muted {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#wireplumber {
    background-color: #282a36;
    color: #ffffff;
}

#wireplumber.muted {
    background-color: #282a36;
}

#custom-media {
    background-color: #66cc99;
    color: #2a5c45;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #66cc99;
}

#custom-media.custom-vlc {
    background-color: #ffa000;
}

#temperature {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#temperature.critical {
    background-color: #${config.stylix.base16Scheme.base0A};
    color: #${config.stylix.base16Scheme.base05};
}

#tray {
    background-color: #${config.stylix.base16Scheme.base00};
    color: #${config.stylix.base16Scheme.base05};
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #eb4d4b;
}

#idle_inhibitor {
    background-color: #2d3436;
}

#idle_inhibitor.activated {
    background-color: #ecf0f1;
    color: #2d3436;
}

#mpd {
    background-color: #66cc99;
    color: #2a5c45;
}

#mpd.disconnected {
    background-color: #f53c3c;
}

#mpd.stopped {
    background-color: #90b1b1;
}

#mpd.paused {
    background-color: #51a37a;
}

#language {
    background: #00b093;
    color: #740864;
    padding: 0 5px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state {
    background: #97e1ad;
    color: #000000;
    padding: 0 0px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state > label {
    padding: 0 5px;
}

#keyboard-state > label.locked {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad.empty {
	background-color: transparent;
}

	" ];
	settings = [ ./configs/waybar/waybar.nix ];
  };
  
  #programs.waybar = import ./configs/waybar/waybarr.nix;
  
  stylix.targets = {
	waybar.enable = false;
	btop.enable = true;
        swaync.enable = true;
        hyprlock.enable = false;
  };
  
  stylix.fonts = {
	monospace = {
      		package = pkgs.nerd-fonts.fira-code;
      		name = "FiraCode Nerd Font Mono";
    	};
    	sansSerif.name = "FiraCode Nerd Font";
    	serif.name = "FiraCode Nerd Font";
  };

  programs.btop = {
	enable = true;
  };
  
  programs.bat = {
	enable = true;
  };

  programs.foot = {
	enable = true;
  };

  programs.gitui = {
	enable = true;
  };

  programs.yazi = {
	enable = true;
  };

  programs.fzf = {
	enable = true;
  };
  
  programs.neovim = {
	enable = true;
	defaultEditor = true;
	plugins = with pkgs.vimPlugins; [
		nvchad-ui
	];
  };

  programs.wlogout = {
	enable = true;
	layout = import ./configs/wlogout/layout.nix;
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

  programs.tmux = {
	enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
