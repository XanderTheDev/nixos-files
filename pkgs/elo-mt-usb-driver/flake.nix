{
  description = "Elo Multi-Touch USB touchscreen driver, repackaged for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.elo-mt-usb-driver =
        pkgs.callPackage ./elo-mt-usb-driver.nix { };

      nixosModules.default = import ./module.nix;
      nixosModules.elo-mt-usb = import ./module.nix;
    };
}
