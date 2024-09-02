{ inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {
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
    border-radius: 15px 15px 15px 15px;
    border-left: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 1px solid #${config.stylix.base16Scheme.base0D};
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
    padding-right: 10px;
    padding-left: 6px;
}
#network {
    border-radius: 15px;
    border: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 8px;
    padding-left: 10px;
}    
#pulseaudio {
    border-radius: 15px 15px 15px 15px;
    border-top: 1px solid #${config.stylix.base16Scheme.base0D};
    border-bottom: 1px solid #${config.stylix.base16Scheme.base0D};
    border-left: 1px solid #${config.stylix.base16Scheme.base0D};
    border-right: 1px solid #${config.stylix.base16Scheme.base0D};
    margin-top: 3px;
    margin-bottom: 3px;
    padding-right: 14px;
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
