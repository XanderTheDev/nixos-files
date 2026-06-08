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
    brave-origin-src = {
      url = "github:WitteShadovv/nixpkgs/brave-origin";
    };
    brother-mfc6490cw-src = {
      url = "github:XanderTheDev/nixpkgs/brother-mfc6490cw";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, stylix, nvf, ... }:
  let
	system = "x86_64-linux";
	host = "nixos";
	username = "xander";
	
        configHash = builtins.hashString "sha256" (
                builtins.toString (builtins.readDir ./configs/nvf)
        );
  in
  {
    packages = {
      ${system} = {
        nvf = (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./configs/nvf/nvf.nix ];
        }).neovim;
      };
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = system;

        specialArgs = {
                inherit inputs;
                inherit system;
        };

        modules = [ 
		./configuration.nix
		
                inputs.nix-flatpak.nixosModules.nix-flatpak

		home-manager.nixosModules.home-manager {
			
			home-manager.extraSpecialArgs = {

				inherit username;
				inherit inputs;
				inherit host;
				
			};

			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "backup";
			
			home-manager.users.xander = import ./home.nix;
		}
		stylix.nixosModules.stylix
		nvf.nixosModules.default
	];
    };

  };
}
