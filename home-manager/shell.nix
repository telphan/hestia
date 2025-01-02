{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;

    autosuggestion = {
      enable = true;
    };
    shellAliases = {
      sl = "eza";
      ls = "eza";
      l = "eza -l";
      la = "eza -la";
      ip = "ip --color=auto";
      g = "git";
      ga = "git add";
      gaa = "git add –all";
      gapa = "git add –patch";
      gc = "git commit";
      gcmsg = "git commit -m";
      gst = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      glg = "git log –stat";
    };

    initExtra = ''
      bindkey '^ ' autosuggest-accept
      AGKOZAK_CMD_EXEC_TIME=5
      AGKOZAK_COLORS_CMD_EXEC_TIME='yellow'
      AGKOZAK_COLORS_PROMPT_CHAR='magenta'
      AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' )
      AGKOZAK_MULTILINE=0
      AGKOZAK_PROMPT_CHAR=( ❯ ❯ ❮ )
      PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      eval $(thefuck --alias)
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      zle && { zle reset-prompt; zle -R }
      autopair-init
                              '';

    plugins = with pkgs; [
      {
        name = "agkozak-zsh-prompt";
        src = fetchFromGitHub {
          owner = "agkozak";
          repo = "agkozak-zsh-prompt";
          rev = "v3.7.0";
          sha256 = "1iz4l8777i52gfynzpf6yybrmics8g4i3f1xs3rqsr40bb89igrs";
        };
        file = "agkozak-zsh-prompt.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-abbrev-alias";
        src = fetchFromGitHub {
          owner = "momo-lab";
          repo = "zsh-abbrev-alias";
          rev = "637f0b2dda6d392bf710190ee472a48a20766c07";
          sha256 = "16saanmwpp634yc8jfdxig0ivm1gvcgpif937gbdxf0csc6vh47k";
        };
        file = "abbrev-alias.plugin.zsh";
      }
      {
        name = "zsh-autopair";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
      {
        name = "zsh-zoxide";
        src = fetchFromGitHub {
          owner = "ajeetdsouza";
          repo = "zoxide";
          rev = "v0.8.1";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "zoxide.plugin.zsh";
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Scripts
  # home.file.".config/zsh/scripts".source = ./files/scripts;
  # home.file.".config/zsh/scripts".recursive = true;
}
