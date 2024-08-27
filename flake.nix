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
	
    homeConfigurations."${username}@${host}" = home-manager.lib.homeManagerConfiguration {
	pkgs = nixpkgs.legacyPackages.${system};
	extraSpecialArgs = {
		inherit inputs;
		inherit username;
		inherit host;
		inherit system;
	};
	modules = [ ./home.nix ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
	specialArgs = { inherit inputs; };
	system = "x86_64-linux";
    	modules = [ ./configuration.nix ];
    };

  };
}
