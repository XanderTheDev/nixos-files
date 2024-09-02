{
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
    background-color: #282a36;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #${config.stylix.base16Scheme.base08};
    box-shadow: inset 0 -3px #ffffff;
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

#window,
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
    background-color: #282a36;
}

#battery {
    background-color: #282a36;
    color: #ffffff;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #282a36;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
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
    background-color: #282a36;
    color: #ffffff;
}

#custom-power_button {
    background-color: #282a36;
}

#memory {
    background-color: #282a36;
}

#disk {
    background-color: #282a36;
}

#backlight {
    background-color: #282a36;
}

#network {
    background-color: #282a36;
}

#network.disconnected {
    background-color: #282a36;
}

#pulseaudio {
    background-color: #282a36;
    color: #ffffff;
}

#pulseaudio.muted {
    background-color: #282a36;
    color: #ffffff;
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
    background-color: #282a36;
}

#temperature.critical {
    background-color: #eb4d4b;
}

#tray {
    background-color: #282a36;
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
settings = [ ./waybar.nix ];
}
