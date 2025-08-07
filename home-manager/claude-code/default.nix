{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    mcp = {
      git.enable = true;
      
      filesystem = {
        enable = true;
        allowedPaths = [ 
          "${config.home.homeDirectory}/repos"
          "${config.home.homeDirectory}/scratchpad"
        ];
      };
      
      github = {
        enable = true;
        tokenFilepath = "${config.home.homeDirectory}/.config/github/token";
      };
    };
  };
}
