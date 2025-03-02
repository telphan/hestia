{pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      sbar-lua = prev.callPackage ./sbarlua.nix {};
    })
  ];

  home.packages = with pkgs; [
    lua54Packages.lua
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
      package.path = "./?.lua;./?/init.lua;" .. package.path
      -- Load the sketchybar-package and prepare the helper binaries
      require("helpers")
      require("init")
    '';
    executable = true;
    onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
  };
}
