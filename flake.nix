{
  description = "Ted's Nix System Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    darwinSystem = {user, arch ? "aarch64-darwin"}:
      darwin.lib.darwinSystem {
        system = arch;
        modules = [
          ./darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            _module.args = { inherit inputs user; };
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              (final: prev: {
                sbar-lua = prev.callPackage ./home-manager/sketchybar/sbarlua.nix {};
              })
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.${user} = import ./home-manager;
              extraSpecialArgs = {
                inherit inputs user;
              };
            };
            users.users.${user}.home = "/Users/${user}";
          }
        ];
      };
  in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            _module.args = { inherit inputs; user = "nixos"; };
            nixpkgs.config.allowUnfree = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nixos = import ./home-manager;
              extraSpecialArgs = {
                inherit inputs;
                user = "nixos";
              };
            };
            nix = {
              settings = {
                allowed-users = [ "root" ];
                trusted-users = [ "root" ];
                max-jobs = 10;
                cores = 10;
                experimental-features = [ "nix-command" "flakes" ];
              };
            };
          }
        ];
      };
    };
    darwinConfigurations = {
      "Theodors-MacBook-Pro" = darwinSystem {
        user = "telphan";
        arch = "aarch64-darwin";
      };
    };
  };
}
