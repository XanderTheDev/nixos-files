{ config, pkgs, ... }:

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
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
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
	package = pkgs.hyprland;
	systemd.enable = true;
	xwayland.enable = true;
  };

  home.file."~/.config/hypr/hyprland.conf".text = "
	
	# See https://wiki.hyprland.org/Configuring/Monitors/
	monitor=,preferred,auto,1

	# See https://wiki.hyprland.org/Configuring/Keywords/ for more

	# Execute your favorite apps at launch
	#exec-once = [workspace 1 silent] brave
	#exec-once = [workspace 2 silent] terminator
	# exec-once = /home/xander/scripts/lockscreentime.sh

	# Source a file (multi-file configs)
	# source = ~/.config/hypr/myColors.conf

	# Some default env vars.
	env = XCURSOR_SIZE,24

	# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
	input {
    	kb_layout = us
    	kb_variant =
    	kb_model =
    	kb_options =
    	kb_rules =

    	follow_mouse = 1

    	touchpad {
        	natural_scroll = yes
    	}

    	sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
	}

	#source= ~/.cache/wal/colors-hyprland.conf

	general {
    	# See https://wiki.hyprland.org/Configuring/Variables/ for more

    	gaps_in = 5
    	gaps_out = 3
    	border_size = 3
    	#col.active_border = $color1 $color5 $color15 90deg
    	#col.inactive_border = $background
    	resize_on_border = true
    	layout = dwindle
	}

	decoration {
	
    	# See https://wiki.hyprland.org/Configuring/Variables/ for more

    	rounding = 10
    
    	blur {
        enabled = true
        size = 4
        passes = 2
    	}

    	drop_shadow = yes
    	shadow_range = 4
    	shadow_render_power = 3
    	col.shadow = rgba(1a1a1aee)
	}

	animations {
    	enabled = yes

    	# Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    	bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    	animation = windows, 1, 7, myBezier
    	animation = windowsOut, 1, 7, default, popin 80%
    	animation = border, 1, 10, default
    	animation = borderangle, 1, 8, default
    	animation = fade, 1, 7, default
    	animation = workspaces, 1, 6, default
	}

	dwindle {
    	# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    	pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    	preserve_split = yes # you probably want this
	}

	master {
    	# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    	new_status = true
	}

	gestures {
    	# See https://wiki.hyprland.org/Configuring/Variables/ for more
    	workspace_swipe = off
	}

	# Example per-device config
	# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
	device {
	
    	name = epic-mouse-v1
    	sensitivity = -0.5
	}

	misc {
    	disable_hyprland_logo = true
	}


	# Example windowrule v1
	# windowrule = float, ^(kitty)$
	# Example windowrule v2
	windowrulev2 = opacity 0.65 0.65,class:^(kitty)$
	windowrulev2 = opacity 0.65 0.65,class:^(alacritty)$
	# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


	# See https://wiki.hyprland.org/Configuring/Keywords/ for more
	$mainMod = SUPER

	# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
	#bind = $mainMod, Q, exec, wlogout
	bind = CTRL ALT, T, exec, terminator
	bind = $mainMod, T, exec, brave
	bind = $mainMod, C, killactive,
	bind = ALT, F4, killactive,
	bind = $mainMod, M, exit, 
	#bind = $mainMod, E, exec, dolphin
	bind = $mainMod, V, togglefloating, 
	bind = $mainMod, R, exec, wofi --show drun
	bind = $mainMod, P, pseudo, # dwindle
	bind = $mainMod, J, togglesplit, # dwindle
	bind = $mainMod SHIFT, K, exec, killall waybar
	bind = $mainMod SHIFT, W, exec, waybar
	bind= $mainMod, F, fullscreen, 1

	# Move focus with mainMod + arrow keys
	bind = $mainMod, left, movefocus, l
	bind = $mainMod, right, movefocus, r
	bind = $mainMod, up, movefocus, u
	bind = $mainMod, down, movefocus, d

	# Switch workspaces with mainMod + [0-9]
	bind = $mainMod, 1, workspace, 1
	bind = $mainMod, 2, workspace, 2
	bind = $mainMod, 3, workspace, 3
	bind = $mainMod, 4, workspace, 4
	bind = $mainMod, 5, workspace, 5
	bind = $mainMod, 6, workspace, 6
	bind = $mainMod, 7, workspace, 7
	bind = $mainMod, 8, workspace, 8
	bind = $mainMod, 9, workspace, 9
	bind = $mainMod, 0, workspace, 10

	# Move active window to a workspace with mainMod + SHIFT + [0-9]
	bind = $mainMod SHIFT, 1, movetoworkspace, 1
	bind = $mainMod SHIFT, 2, movetoworkspace, 2
	bind = $mainMod SHIFT, 3, movetoworkspace, 3
	bind = $mainMod SHIFT, 4, movetoworkspace, 4
	bind = $mainMod SHIFT, 5, movetoworkspace, 5
	bind = $mainMod SHIFT, 6, movetoworkspace, 6
	bind = $mainMod SHIFT, 7, movetoworkspace, 7
	bind = $mainMod SHIFT, 8, movetoworkspace, 8
	bind = $mainMod SHIFT, 9, movetoworkspace, 9
	bind = $mainMod SHIFT, 0, movetoworkspace, 10

	# Scroll through existing workspaces with mainMod + scroll
	bind = $mainMod, mouse_down, workspace, e+1
	bind = $mainMod, mouse_up, workspace, e-1

	# Move/resize windows with mainMod + LMB/RMB and dragging
	bindm = $mainMod, mouse:272, movewindow
	bindm = $mainMod, mouse:273, resizewindow
  ";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
