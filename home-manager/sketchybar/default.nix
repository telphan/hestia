{pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      sbar-lua = prev.callPackage ./sbarlua.nix {};
    })
  ];

  home.packages = with pkgs; [
    sketchybar-app-font
    sbar-lua
  ];

  home.file.".config/sketchybar" = {
    source = ./config;
    recursive = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
  home.file.".local/share/sketchybar_lua/sketchybar.so" = {
    source = "${pkgs.sbar-lua}/lib/sketchybar.so";
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
  home.file.".config/sketchybar/sketchybarrc" = {
    text = ''
      #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua

      require("helpers")
      require("init")

      -- Enable hot reloading
      sbar.exec("sketchybar --hotload true")      
    '';
    executable = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
}
