{ config, pkgs, ... }: {
  homebrew = {
    casks = [
      # "qutebrowser"
      "alacritty"
      "1password"
      "amethyst"
      "docker"
      "spotify"
      "slack"

      # Work
      "zoom"
      "rapidapi"
      "wkhtmltopdf"

      "dteoh-devdocs"
    ];
    brews = [
      # Work
      "nodejs"
      "erlang"
      "openjdk"
      "java"
      "elixir"
      "coreutils"
      "asdf"
      "macos-term-size"
      "node"
      "xz"
      "yarn"
    ];
    masApps = {
    };
  };
}
