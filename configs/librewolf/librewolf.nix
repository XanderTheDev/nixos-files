{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

    programs.librewolf = {
    enable = true;
    settings = {
      # Start with a blank page
      "browser.startup.page" = 0;

      # Disable default browser check
      "browser.shell.checkDefaultBrowser" = false;

      # Disable animations for faster UI response
      "toolkit.cosmeticAnimations.enabled" = false;

      # Disable welcome / onboarding page
      "startup.homepage_welcome_url" = "";
      "startup.homepage_welcome_url.additional" = "";

      # Just in case: ensure Pocket is off (LibreWolf usually disables this already)
      "extensions.pocket.enabled" = false;

    };
    profiles.default = {
	search.engines = {
		"Nix Packages" = {
			urls = [{
				template = "https://search.nixos.org/packages";
				params = [
					{ name = "type"; value = "packages"; }
					{ name = "query"; value = "{searchTerms}"; }
				];
			}];
			icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
			definedAliases = [ "@np" ];
		};
	};
	search.force = true;
	extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
		sponsorblock
		darkreader
		youtube-shorts-block
	];
    };
  };

}
