{ config, lib, pkgs, ... }:
{
  imports = [ 
    ./git.nix
    ./shell.nix
    ./term.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "telphan";
  home.homeDirectory = "/Users/telphan";
  home.packages = with pkgs; [
    gh
    jq
    neovim
    ripgrep
    exa
    nerdfonts
    _1password
    thefuck
    terminal-notifier
    direnv
    gnupg
    pinentry
    go_1_18
    zoxide
    fzy
    fd

    # Work
    #elixir
    #erlang
    postgresql
    kind
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "GitHub";
      italic-text= "always";
    };
  };

  xdg.configFile.nvim = {
    source = ./dotfiles/neovim;
    recursive = true;
  };

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home.file.".qutebrowser/config.py".source = ./dotfiles/qutebrowser/config.py;
  home.file.".qutebrowser/userscripts/1password".source = ./dotfiles/qutebrowser/userscripts/1password;

#  home.activation = {
#    copyApplications = let
#      apps = pkgs.buildEnv {
#        name = "home-manager-applications";
#        paths = config.home.packages;
#        pathsToLink = "/Applications";
#      };
#    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
#      baseDir="$HOME/Applications/Home Manager Apps"
#      if [ -d "$baseDir" ]; then
#        rm -rf "$baseDir"
#      fi
#      mkdir -p "$baseDir"
#      for appFile in ${apps}/Applications/*; do
#        target="$baseDir/$(basename "$appFile")"
#        $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
#        $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
#      done
#    '';
#  };

  home.stateVersion = "21.11";
}
