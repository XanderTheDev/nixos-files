{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    brother-mfc6490cw-src = {
      url = "github:XanderTheDev/nixpkgs/brother-mfc6490cw";
    };
    cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, stylix, nvf, ... }:
  let
    system = "x86_64-linux";
    username = "xander";

    configHash = builtins.hashString "sha256" (
      builtins.toString (builtins.readDir ./configs/nvf)
    );

    mkHost = host: extraModules: nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = { inherit inputs system username host; };
      modules = [
        ./configuration.nix
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.disko.nixosModules.disko
        stylix.nixosModules.stylix
        nvf.nixosModules.default
        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = { inherit username inputs host; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.xander = import ./home.nix;
        }
      ] ++ extraModules;
    };
  in
  {
    packages.${system} = {
      nvf = (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./configs/nvf/nvf.nix ];
      }).neovim;

      iso-laptop = (mkHost "laptop" [
        ./hosts/laptop
        ./installer.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        {
          boot.initrd.systemd.enable = nixpkgs.lib.mkForce false;
          boot.loader.timeout = nixpkgs.lib.mkForce 10;
          isoImage.squashfsCompression = "zstd -Xcompression-level 6";
          services.greetd.enable = nixpkgs.lib.mkForce false;
          services.getty.autologinUser = nixpkgs.lib.mkForce "nixos";
        }
      ]).config.system.build.isoImage;
      iso-thinkpad = (mkHost "thinkpad" [
        ./hosts/thinkpad
        ./installer.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        {
          boot.initrd.systemd.enable = nixpkgs.lib.mkForce false;
          boot.loader.timeout = nixpkgs.lib.mkForce 10;
          isoImage.squashfsCompression = "zstd -Xcompression-level 6";
          services.greetd.enable = nixpkgs.lib.mkForce false;
        }
      ]).config.system.build.isoImage;
    };

    nixosConfigurations = {
      laptop = mkHost "laptop" [
        ./hosts/laptop
      ];
      thinkpad = mkHost "thinkpad" [
        ./hosts/thinkpad
      ];
    };
  };
}
