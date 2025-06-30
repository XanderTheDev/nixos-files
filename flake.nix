{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
	url = "github:nix-community/home-manager?ref=release-25.05";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
	url = "github:danth/stylix/release-25.05";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
	url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, stylix, ... }@inputs:
  let
	system = "x86_64-linux";
	host = "nixos";
	username = "xander";
	
	pkgs = import nixpkgs {
		inherit system;
		config.allowUnfree = true;
	};
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
	system = "${system}";
	specialArgs = { inherit inputs; };
    	modules = [ 
		./configuration.nix
		
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
	];
    };

  };
}
