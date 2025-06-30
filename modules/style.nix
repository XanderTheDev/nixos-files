{ inputs, pkgs, lib, config, ... }:

{

  stylix.enable = true;
  stylix.image = ../wallpapers/lake-sunrise.jpg;
  stylix.polarity = "dark";

  fonts.packages = with pkgs; [
        font-awesome
	noto-fonts
	nerd-fonts.fira-code
	cantarell-fonts
	roboto
	fira
	dejavu_fonts
	liberation_ttf
  ];

}
