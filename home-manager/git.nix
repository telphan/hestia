{ config, pkgs, ... }:
{
  programs.git  = {
    enable = true;
    userName = "Theodor Ghezan";
    userEmail = "theodor@duffel.com";
    signing = {
      key = "6A7156F77E2B2B94";
      signByDefault = true;
    };
    aliases = {
      prettylog = "...";
    };
    extraConfig = {
      core = {
        editor = "nvim";
      };
      color = {
        ui = true;
      };
      push = {
        default = "simple";
      };
      pull = {
        ff = "only";
      };
      init = {
        defaultBranch = "main";
      };
    };
    ignores = [
      ".DS_Store"
      "*.pyc"
      "bash_utils"
      "nix"
      ".envrc"
      "devenv*"
      ".devenv*"
    ];
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "GitHub";
      };
    };
  };
}
