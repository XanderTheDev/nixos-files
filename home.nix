{ config, pkgs, lib, ... }:

with lib;
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "xander";
  home.homeDirectory = "/home/xander";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/xander/etc/profile.d/hm-session-vars.sh
  #
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
  
  programs.waybar = {
	enable = true;
	settings = [
	{
    		layer = "top"; # Waybar at top layer
    		position = "top"; # Waybar position (top|bottom|left|right)
    		height = 30; # Waybar height (to be removed for auto height)
    		spacing = 10; # Gaps between modules (4px)
    		modules-left = ["hyprland/workspaces" "hyprland/window" "wlr/taskbar"];
    		modules-center = [];
    		modules-right = ["network" "pulseaudio" "backlight" "clock" "cpu" "temperature" "battery" "tray" "custom/power_button" "custom/space"];
    
    		#"group/laptop" = {
		#	orientation = "horizontal";
		#	modules = ["pulseaudio" "backlight"];
	    #   };
    		"custom/power_button" = {
			orientation = "horizontal";
			format = "⏻";
			on-click = "/usr/bin/wlogout";
    		};
    		"custom/space" = {
		orientation = "horizontal";
		format = " ";
 	     #  };
   		# "group/hardware" = {
		#	orientation = "horizontal";
		#	modules = ["cpu" "temperature" "battery"];
	      #   };	
    		"tray" = {
        		# icon-size = 21;
        		spacing = 10;
    		};
    		"clock" = {
        		# timezone = "America/New_York";
			interval = 1;
			format = "{:%T}";
		#       tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        		format-alt = "{:%a %d %B}";
    		};
    		"cpu" = {
        		format = "{usage}% ";
        		tooltip = true;
    		};
    		"memory" = {
        		format = "{}% ";
    		};
    		"temperature" = {
        		# thermal-zone = 2;
        		# hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        		critical-threshold = 80;
        		# format-critical = "{temperatureC}°C {icon}";
        		format = "{temperatureC}°C {icon}";
        		format-icons = ["" "" ""];
    		};
    		"backlight" = {
        		# device = "acpi_video1";
        		format = "{percent}% {icon}";
        		format-icons = ["☼" "☼" "𖤓" "𖤓" "☀︎" "☀︎" "🔆" "☀️" "🌞"];
    		};
    		"battery" = {
        		states = {
            			# good = 95;
            			warning = 30;
            			critical = 15;
        		};
        		format = "{capacity}% {icon}";
        		format-charging = "{capacity}% ";
        		format-plugged = "{capacity}% ";
        		format-alt = "{time} {icon}";
        		# format-good = ""; # An empty format will hide the module
        		# format-full = "";
        		format-icons = ["" "" "" "" ""];
    		};
    		"network" = {
        		# interface = "wlp2*"; # (Optional) To force the use of this interface
        		format-wifi = "{essid} ";
        		format-ethernet = "{ipaddr}/{cidr} ";
        		tooltip-format = "{ifname} via {gwaddr}";
        		format-linked = "{ifname} (No IP) ";
        		format-disconnected = "Disconnected ⚠";
        		format-alt = "{ifname}: {ipaddr}/{cidr}";
    		};
    		"pulseaudio" = {
        		# scroll-step = 1; # %, can be a float
			format = "{volume}% {icon}";
        		format-bluetooth = "{volume}% {icon} {format_source}";
        		format-bluetooth-muted = " {icon} {format_source}";
        		format-icons = {
            		default = ["" "" ""];
        	};
        	on-click = "pavucontrol";
    		};
	#      "custom/media" = {
		#        format = "{icon} {}";
		#        return-type = "json";
		#        max-length = 40;
		#        format-icons = {
		#            spotify = "";
		#            default = "🎜";
		#        };
		#        escape = true;
		#        exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
		#        # exec = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
	#    	};
	  };
	];
	style = concatStrings [ ./configs/waybar/waybarstyle.css ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
