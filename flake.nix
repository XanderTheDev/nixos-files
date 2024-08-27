{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }:
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
			home-manager.useGlobalPkgs = true;
			home-manager.useUserPkgs = true;
			
			home-manager.users.xander = import ./home.nix;
		}
	];
    };

  };
}
