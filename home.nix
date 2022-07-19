{ config, lib, pkgs, ... }:
{
  imports = [ 
    ./modules/applications/git.nix
    ./modules/applications/shell.nix
    ./modules/applications/term.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "ted";
  home.homeDirectory = "/Users/ted";
  home.packages = with pkgs; [
    jq
    neovim
    ripgrep
    exa
    nerdfonts
    _1password
    thefuck
     
    # Work
    postgresql
    kind
    asdfyu
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "GitHub";
      italic-text= "always";
    };
  };

  xdg.configFile.nvim = {
    source = ./files/neovim;
    recursive = true;
  };

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home.activation = {
    copyApplications = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      baseDir="$HOME/Applications/Home Manager Apps"
      if [ -d "$baseDir" ]; then
        rm -rf "$baseDir"
      fi
      mkdir -p "$baseDir"
      for appFile in ${apps}/Applications/*; do
        target="$baseDir/$(basename "$appFile")"
        $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
        $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
      done
    '';
  };

  home.stateVersion = "22.05";
}
