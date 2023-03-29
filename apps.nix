{ config, pkgs, ... }: {
  homebrew = {
    casks = [
      "qutebrowser"
      "alacritty"
      "1password"
      "amethyst"
      "docker"
      "spotify"
      "slack"
      "google-cloud-sdk"

      # Work
      "zoom"
      "paw"
      "wkhtmltopdf"
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
      "aichat"
    ];
    masApps = {
    };
  };
}
