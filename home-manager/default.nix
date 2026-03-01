{ config, lib, pkgs, inputs, ... }:
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
    lua54Packages.lua

    gh
    jq
    neovim
    ripgrep
    eza
    _1password-cli
    terminal-notifier
    direnv
    devenv
    gnupg
    go
    zoxide
    fzy

    httpyac
    fd

    # Managed by asdf
    #elixir
    #erlang


    just
    zig

    postgresql

(google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])

    argocd
    awscli2
    hcloud
    nodejs_22
    ollama
    tailscale
    nomad
    packer
    terraform
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
