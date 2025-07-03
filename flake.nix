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
    nvf = {
	url = "github:notashelf/nvf";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    brother-mfc-6490cw-flake = {
        url = "github:xanderthedev/nixos-files#brother-mfc-6490cw-flake";
    };
  };

  outputs = { brother-mfc-6490cw-flake, nixpkgs, home-manager, stylix, nvf, ... }@inputs:
  let
	system = "x86_64-linux";
	host = "nixos";
	username = "xander";
	
	pkgs = import nixpkgs {
		inherit system;
		config.allowUnfree = true;
	};
        configHash = builtins.hashString "sha256" (
                builtins.toString (builtins.readDir ./configs/nvf)
        );
  in
  {
    packages.${system}.nvf = 
	(nvf.lib.neovimConfiguration {
	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
	  modules = [ ./configs/nvf/nvf.nix ];
	}).neovim;
    
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
		nvf.nixosModules.default
                brother-mfc-6490cw-flake.nixosModules.${system}.brother-mfc-6490cw-FilterModule
	];
    };

  };
}
