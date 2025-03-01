{ pkgs, lib, ... }: 
let 
  yamlThemeFromGithub = {url, ref, path, rev}:
    builtins.fromJSON (builtins.readFile (pkgs.stdenv.mkDerivation {
      name = "yamlThemeFromGithub";
      phases = [ "buildPhase" ];
      src = builtins.fetchGit {
        url = url;
        ref = ref;
	rev = rev;
      };
      buildPhase = ''
        cat "$src/${path}" | ${pkgs.yaml2json}/bin/yaml2json > $out
      '';
    }));
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Hack Nerd Font Mono";
        size = 15;
        bold = { style = "Bold"; };
      };

      window.padding = {
        x = 2;
        y = 2;
      };

      window.decorations = "buttonless";

      terminal.shell = "${pkgs.zsh}/bin/zsh";

      cursor.style = "Beam";
      colors = (yamlThemeFromGithub {
        url = "https://github.com/projekt0n/github-theme-contrib.git";
	ref = "refs/tags/v1.0.2";
	path = "/themes/alacritty/github_dark_default.yml";
	rev = "e0d4d1c8a0c02c0d1b489fa195fb934fdde2d089";
      }).colors;

      keyboard.bindings = [
        { key = "Key3";     mods = "Alt";     chars = "#"; }
      ];
    };
  };
}
