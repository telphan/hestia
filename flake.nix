{
  description = "Ted's Nix System Configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
            _module.args = { inherit inputs; };
            home-manager = {
              users.${user} = import ./home-manager;
            };
            users.users.${user}.home = "/Users/${user}";
            nix.settings.trusted-users = [ user ];
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
            home-manager = {
              users.nixos = import ./home-manager;

            };

            nix = {
              settings = {
                allowed-users = [ "telphan" "root" ];
                trusted-users = [ "telphan" "root" ];
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
      "AMR22" = darwinSystem {
        user = "telphan";
        arch = "x86_64-darwin";
      };
    };
  };
}
