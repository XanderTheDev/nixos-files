{ inputs, config, pkgs, lib, ... }:

with inputs;
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

  imports = [
	inputs.ags.homeManagerModules.default	
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
    "~/.config/wofi/style.css".text = ./configs/wofi/style.css;
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
	package = pkgs.waybar;
	style = concatStrings [ ./configs/waybar/waybarstyle.css ];
	settings = [ ./configs/waybar/waybar.nix ];
  };
  
  stylix.targets = {
	waybar.enable = false;
  };
  
  programs.neovim = {
	enable = true;
	defaultEditor = true;
	plugins = with pkgs.vimPlugins; [
		nvchad-ui
	];
  };

  programs.ags = {
	enable = true;
	configDir = ./configs/ags;

  };

  programs.wofi = {
	enable =true;
	style = [ ./configs/wofi/style.css ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
