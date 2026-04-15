{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  programs.fastfetch = {
	enable = true;

    	settings = {

      logo = {
        source = ''
\u001b[38;5;202m                  -===========-
             -=====================- 
          -===========================-
        -===============================-
      -===================================-
    -=======================================-
   -=====+=============================+=====- 
  -======   -=======================-   ======- 
 -=======     -===================-     =======-
 \u001b[37m ========       -===============-       ======== 
\u001b[38;5;202m-========         -===========-         ========-
=========           -=======-           =========
=========     .       -===-       .     =========
-========     ::.       +       .::     ========-
 \u001b[37m========     ::::.           .::::     ======== 
          ::::::.       .::::::
          ::::::::.   .:::::::
          ::::::::::.::::::::::
 ...........:::::::::::::::::::::...........
  *:::::::::::::::::::::::::::::::::::::::*
    *:::::::::::::::::::::::::::::::::::*
      *:::::::::::::::::::::::::::::::*
        *:::::::::::::::::::::::::::*
            *:::::::::::::::::::*
                  *********
\u001b[0m
        '';
        type = "auto";   # tells fastfetch to read ASCII text
        padding = {
          top = 1;
          left = 2;
          };
      };

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

}
