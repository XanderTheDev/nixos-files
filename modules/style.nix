{ inputs, pkgs, lib, config, ... }:

{

  # Enabling stylix, setting background and setting theme to dark
  stylix.enable = true;
  stylix.image = ../wallpapers/lake-sunrise.jpg;
  stylix.polarity = "dark";

  # Fonts
  fonts.packages = with pkgs; [
        font-awesome
	noto-fonts
	nerd-fonts.fira-code
	cantarell-fonts
	roboto
	fira
	dejavu_fonts
	liberation_ttf
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        corefonts
  ];

}
