{ config, pkgs, lib, inputs, ... }:
{
  imports = [ inputs.mcp-servers-nix.homeManagerModules.default ];

  programs.mcp-servers = {
    enable = true;
    
    format = "json";
    flavor = "claude"; # or "vscode"
    fileName = "claude_code_config.json";
    
    filesystem = {
      enable = true;
      settings = {
        allowedPaths = [
          "${config.home.homeDirectory}/repos"
          "${config.home.homeDirectory}/scratchpad"
        ];
      };
    };
    
    git = {
      enable = true;
    };
    
    github = {
      enable = true;
      passwordCommand = {
        GITHUB_PERSONAL_ACCESS_TOKEN = [ "cat" "${config.home.homeDirectory}/.config/github/token" ];
      };
    };
  };
}
