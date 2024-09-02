{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    home-manager = {
	url = "github:nix-community/home-manager?ref=release-24.05";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
	url = "github:Aylur/ags";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
	url = "github:danth/stylix";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, stylix, ... }:
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
	system = "x86_64-linux";
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
