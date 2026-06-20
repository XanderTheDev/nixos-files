{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
  colors = config.lib.stylix.colors.withHashtag;
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  videoBackgroundPlayFix = pkgs.fetchFirefoxAddon {
    name = "video-background-play-fix";
    url = "https://addons.mozilla.org/firefox/downloads/file/4394140/video_background_play_fix-1.8.1.xpi";
    hash = "sha256-sE5+SJJitcm81Nv4IZpL1vtmXQ/3z59FJu2gFHAl9VA=";
  };
  noScript = pkgs.fetchFirefoxAddon {
    name = "no-script";
    url = "https://addons.mozilla.org/firefox/downloads/file/4841405/noscript-13.6.23.xpi";
    hash = "sha256-2Nmxntz3NW+BmvF6zogNvlm43YmMHLi1sGoB5vGYQL0=";
  };
  returnYoutubeDislikes = pkgs.fetchFirefoxAddon {
    name = "return-youtube-dislikes";
    url = "https://addons.mozilla.org/firefox/downloads/file/4371820/return_youtube_dislikes-3.0.0.18.xpi";
    hash = "sha256-LTOXfOkydlN1QxYfjgXDYS9xVWhArh65gjkoS4+LoZ4=";
  };
  
  dohUrl = let
    secretDohUrl = ./doh_url.nix;
  in
    if builtins.pathExists secretDohUrl
    then import secretDohUrl
    else "https://dns.quad9.net/dns-query";

  searchEngineUrl = let
    secretSearchEngine = ./search_engine.nix;
  in
    if builtins.pathExists secretSearchEngine
    then import secretSearchEngine
    else "https://duckduckgo.com/?q={searchTerms}";
in {

  stylix.targets.firefox.profileNames = [ "default" ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    profiles.default = {
      search = {
        force = true;
        default = "Default";
        engines = {
          "Default" = {
            urls = [{ template = searchEngineUrl; }];
            definedAliases = [ "@b" ];
          };
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
          "google".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };
      extraConfig = builtins.readFile "${pkgs.arkenfox-userjs}/user.js";
      extensions.packages = [
        addons.ublock-origin
        addons.sponsorblock
        addons.clearurls
        addons.darkreader
        addons.privacy-badger
        addons.youtube-shorts-block
        videoBackgroundPlayFix
        noScript
        returnYoutubeDislikes
      ];
      settings = {
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.letterboxing" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts" = true;
        "privacy.resistFingerprinting.randomDataOnCanvasExtract" = true;
        "privacy.resistFingerprinting.reduceTimerPrecision.jitter" = true;
        "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
        "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
        "network.cookie.cookiebehavior" = 5;
        "privacy.trackingprotection.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "browser.ping-centre.telemetry" = false;
        "extensions.pocket.enabled" = false;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;
        "dom.security.https_only_mode" = true;
        "extensions.autoDisableScopes" = 0;
        "network.trr.mode" = 3;
        "network.trr.uri" = dohUrl;
        "browser.shell.checkDefaultBrowser" = false;
        "toolkit.cosmeticAnimations.enabled" = false;
        "startup.homepage_welcome_url" = "";
        "startup.homepage_welcome_url.additional" = "";
        "accessibility.force_disabled" = 1;
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.update.auto" = false;
        "browser.startup.firstrunSkipsHomepage" = true;
        "browser.newtab.preload" = true;
        "datareporting.usage.uploadEnabled" = false;
        "network.http.speculative-parallel-limit" = 6;
        "network.dns.disablePrefetchFromHTTPS" = false;
        "dom.security.https_only_mode_send_http_background_request" = true;
      };
    };
  };
}
