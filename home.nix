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

  home.packages = with pkgs; [
        protonup-ng
  ];

  home.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS =
                "\${HOME}/.steam/root/Steam/compatibilitytools.d";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
        "inode/directory" = "thunar.desktop";
        "text/*" = [
          "nvim.desktop"
        ];
      };
    };
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = ["gtk"];
        };
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
    };
  };

  imports = [	
  	./configs/zsh/zsh.nix
	./configs/librewolf/librewolf.nix
        ./configs/brave/brave.nix
	./configs/desktop/settings.nix
	./configs/hypr/hypr-eco.nix
	./configs/fastfetch/fastfetch.nix
	./configs/waybar/waybar.nix
	./configs/stylix/stylix.nix
	./configs/btop/btop.nix
	./configs/bat/bat.nix
	./configs/foot/foot.nix
	./configs/gitui/gitui.nix
	./configs/yazi/yazi.nix
	./configs/fzf/fzf.nix
	./configs/wlogout/wlogout.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
