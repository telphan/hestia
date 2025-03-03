{ config, lib, pkgs, ... }:
{
  imports = [ 
    ./git.nix
    ./shell.nix
    ./term.nix
    ./sketchybar/default.nix
    ./karabiner/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "telphan";
  home.homeDirectory = "/Users/telphan";
  home.packages = with pkgs; [
    gh
    jq
    neovim
    ripgrep
    eza
    _1password
    terminal-notifier
    direnv
    gnupg
    go
    zoxide
    fzy

    fd

    # Work
    #elixir
    #erlang

    postgresql

   (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "GitHub";
      italic-text= "always";
    };
  };

  xdg.enable = true;

  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
