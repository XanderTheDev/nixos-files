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
    };
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
        device = "acpi_video1";
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
#    "custom/media" = {
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
#    };
}
