{ pkgs, lib, ... }: 
let 
  yamlThemeFromGithub = {url, ref, path}:
    builtins.fromJSON (builtins.readFile (pkgs.stdenv.mkDerivation {
      name = "yamlThemeFromGithub";
      phases = [ "buildPhase" ];
      src = builtins.fetchGit {
        url = url;
        ref = ref;
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

      shell.program = "${pkgs.zsh}/bin/zsh";

      cursor.style = "Beam";
      colors = (yamlThemeFromGithub {
        url = "https://github.com/projekt0n/github-nvim-theme.git";
	ref = "refs/tags/v0.0.4";
	path = "/terminal/alacritty/github_dark_default.yml";
      }).colors;

      key_bindings = [
        { key = "Key3";     mods = "Alt";     chars = "#"; }
      ];
    };
  };
}
