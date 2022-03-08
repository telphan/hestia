{ config, pkgs, ... }: {
  imports = [ 
     <home-manager/nix-darwin>
    ./preferences.nix
    ./brew.nix
    ./network.nix
    ./modules/security/pam.nix
    ./apps.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      docker
      docker-compose
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
    allowedUsers = [ "telphan" ];
    trustedUsers = [ "telphan" ];
    maxJobs = 10;
    buildCores = 10;
    package = pkgs.nix;
  };

  home-manager = {
    useUserPackages = true;
    users.telphan = import ./home-manager;
  };

  system.stateVersion = 4;
}
