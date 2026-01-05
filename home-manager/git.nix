{ config, pkgs, ... }:
{
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "GitHub";
    };

    enableGitIntegration = true;
  };
  programs.git  = {
    enable = true;
    lfs.enable = true;

    signing = {
      key = "6A7156F77E2B2B94";
      signByDefault = true;
    };

    settings = {

      user = {
        name = "Theodor Ghezan"; 
        email = "theodor@duffel.com";
      };

      alias = {
        prettylog = "...";
      };

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
      net = {
        "git-fetch-with-cli" = true;
      };

      diff.gz = {
        textconv = "zcat";
        cachetextconv = true;
        binary = true;
      };
    };

    attributes = [
      "*.gz diff=gz"
    ];

    ignores = [
      ".DS_Store"
      "*.pyc"
      "bash_utils"
      "nix"
      ".envrc"
      "devenv*"
      ".devenv*"
      ".direnv"
      ".env"
      ".httpyac*"
      "httpyac.config.js"
      "http_collections"
      "scratch/"
    ];
  };
}
