{ config, pkgs, ... }: {
  imports = [ 
     <home-manager/nix-darwin>
    ./preferences.nix
    ./brew.nix
    ./network.nix
    ./apps.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      docker-compose
      cachix
      (import (fetchTarball https://github.com/cachix/devenv/archive/v0.6.2.tar.gz)).default
    ];
    shells = [ pkgs.zsh ];
  };

  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  programs.zsh.enable = true;

  users.users.telphan = {
    name = "telphan";
    home = "/Users/telphan";
  };

  nix = {
    settings = {
      allowed-users = [ "telphan" "root" ];
      trusted-users = [ "telphan" "root" ];
      max-jobs = 10;
      cores = 10;
    };

    package = pkgs.nix;
  };

  home-manager = {
    useUserPackages = true;
    users.telphan = import ./home-manager;
  };

  system.stateVersion = 4;
}
