{
  description = "Brother MFC-6490CW CUPS filter driver";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.brother-mfc-6490cw-Filter = import ./pkgs/brother-mfc6490-cw {
      stdenv = pkgs.stdenv;
      lib = pkgs.lib;
    };

    # Optional nixos module to add the package to environment.systemPackages
    nixosModules.${system}.brother-mfc-6490cw-FilterModule = {
      config, pkgs, ... }: {
        environment.systemPackages = [
          self.packages.${system}.brother-mfc-6490cw-Filter
        ];
      };
  };
}

