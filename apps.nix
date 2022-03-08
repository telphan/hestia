{ config, pkgs, ... }: {
  homebrew = {
    casks = [
      "qutebrowser"
      "alacritty"
      "1password"
      "amethyst"
      "docker"

      # Work
      "zoom"
      "paw"
      "slack"
    ];
    brews = [
    ];
    masApps = {
    };
  };
}
 
