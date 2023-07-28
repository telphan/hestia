{ config, pkgs, ... }: {
  homebrew = {
    enable = true;
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    global = {
      brewfile =  true;
    };
    onActivation = {
      upgrade = true;
      cleanup = "zap";
      autoUpdate = true;
    };
    taps = [
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];
  };
}
