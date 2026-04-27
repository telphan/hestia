{ config, lib, pkgs, inputs, user, ... }:
{
  imports = [
    ./git.nix
    ./shell.nix
    ./starship.nix
    ./term.nix
    ./sketchybar/default.nix
    ./karabiner/default.nix
  ];

  home.username = user;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${user}"
    else "/home/${user}";

  home.packages = with pkgs; [
    lua54Packages.lua

    gh
    jq
    neovim
    ripgrep
    eza
    _1password-cli
    terminal-notifier
    devenv
    gnupg
    go
    zoxide
    fzy

    httpyac
    fd
    ncurses

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
    terraform
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "GitHub";
      italic-text = "always";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
