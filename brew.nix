{ config, pkgs, ... }: {
  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "zap";
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    global = {
      brewfile = true;
      noLock = true;
    };
    taps = [
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];
  };
}
