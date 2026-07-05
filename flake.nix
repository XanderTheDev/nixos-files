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

    userDefaults = { username = "xander"; };
    userConfig = if builtins.pathExists ./user.nix
                 then userDefaults // (import ./user.nix)
                 else userDefaults;
    inherit (userConfig) username;

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
          home-manager.users.${username} = import ./home.nix;
        }
      ] ++ extraModules;
    };

    genericGpuModules = {
      amd          = [ ./modules/hardware/amd-gpu.nix ];
      intel        = [ ./modules/hardware/intel-gpu.nix ];
      nvidia       = [ ./modules/hardware/nvidia.nix ];
      intel-nvidia = [ ./modules/hardware/prime-intel-nvidia.nix ];
      amd-nvidia   = [ ./modules/hardware/prime-amd-nvidia.nix ];
      intel-amd    = [ ./modules/hardware/prime-intel-amd.nix ];
    };

    genericProfiles = {
      laptop-amd           = genericGpuModules.amd;
      laptop-intel         = genericGpuModules.intel;
      laptop-intel-nvidia  = genericGpuModules.intel-nvidia;
      laptop-intel-amd     = genericGpuModules.intel-amd;
      laptop-amd-nvidia    = genericGpuModules.amd-nvidia;
      laptop-generic       = [];
      desktop-amd          = genericGpuModules.amd;
      desktop-intel        = genericGpuModules.intel;
      desktop-nvidia       = genericGpuModules.nvidia;
      desktop-intel-nvidia = genericGpuModules.intel-nvidia;
      desktop-intel-amd    = genericGpuModules.intel-amd;
      desktop-amd-nvidia   = genericGpuModules.amd-nvidia;
      desktop-generic      = [];
    };

    mkGenericHost = profileId: gpuModules: mkHost profileId ([

      ./hosts/generic/hardware-defaults.nix
      ./hosts/generic/disks.nix
      ./modules/hardware/amd-cpu.nix
      ./modules/hardware/intel-cpu.nix
      { networking.hostName = profileId; }

    ] ++ gpuModules);

    genericHosts = nixpkgs.lib.mapAttrs mkGenericHost genericProfiles;

    isoOverrides = {
      services.xserver.displayManager.lightdm.enable = nixpkgs.lib.mkForce false;
      services.displayManager.gdm.enable = nixpkgs.lib.mkForce false;
      services.displayManager.sddm.enable = nixpkgs.lib.mkForce false;
      services.xserver.enable = nixpkgs.lib.mkForce false;
      stylix.autoEnable = nixpkgs.lib.mkForce false;
      services.desktopManager.plasma6.enable = nixpkgs.lib.mkForce false;
      qt.enable = nixpkgs.lib.mkForce false;
      services.colord.enable = nixpkgs.lib.mkForce false;
      system.activationScripts.stylix-kde = nixpkgs.lib.mkForce ""; 
      boot.initrd.systemd.enable = nixpkgs.lib.mkForce false;
      boot.loader.timeout = nixpkgs.lib.mkForce 10;
      isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      boot.zfs.forceImportRoot = false;

      services.greetd.enable = nixpkgs.lib.mkForce false;
      programs.hyprland.enable = nixpkgs.lib.mkForce false;

      users.users.xdos = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" "input" "render" "seat" ];
        initialPassword = "";
      };

      services.getty.autologinUser = nixpkgs.lib.mkForce "xdos";

      xdg.portal.extraPortals = nixpkgs.lib.mkForce (with nixpkgs.legacyPackages.${system}; [
        xdg-desktop-portal-gtk
      ]);

      systemd.services."getty@tty1".enable = nixpkgs.lib.mkForce true;
      systemd.services."getty@tty1".wantedBy = nixpkgs.lib.mkForce [ "getty.target" ];

      isoImage.appendToMenuLabel = " 26.05";
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
        isoOverrides
      ]).config.system.build.isoImage;

      iso-thinkpad = (mkHost "thinkpad" [
        ./hosts/thinkpad
        ./installer.nix
        ./hosts/thinkpad/installer-extra.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        isoOverrides
      ]).config.system.build.isoImage;

      iso-generic = (mkHost "generic-installer" [
        ./installer.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        isoOverrides
        {
          system.extraDependencies =
            nixpkgs.lib.mapAttrsToList (_: host: host.config.system.build.toplevel) genericHosts;
        }
      ]).config.system.build.isoImage;
    };

    nixosConfigurations = {
      laptop = mkHost "laptop" [ ./hosts/laptop ];
      thinkpad = mkHost "thinkpad" [ ./hosts/thinkpad ];
    } // genericHosts;
  };
}
