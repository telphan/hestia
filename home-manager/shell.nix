{ config, lib, pkgs, ... }:
let
  ccrSessions = ./scripts/ccr-sessions.py;
in
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
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
      gaa = "git add --all";
      gapa = "git add --patch";
      gc = "git commit";
      gcmsg = "git commit -m";
      gst = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      glg = "git log --stat";
    };

    initContent = ''
      . "${pkgs.asdf-vm}/etc/profile.d/asdf-prepare.sh"

      bindkey '^ ' autosuggest-accept
      PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(zoxide init zsh)"
      zle && { zle reset-prompt; zle -R }
      autopair-init

      # --- Claude Code cross-project session picker -------------------
      _ccr_pick() {
        python3 ${ccrSessions} | \
          fzf --ansi --delimiter=$'\t' --with-nth=1,2,4 \
              --preview="python3 ${ccrSessions} {3}" \
              --preview-window=down:50%:wrap
      }

      ccr() {
        local pick cwd uuid
        pick=$(_ccr_pick) || return
        [[ -z "$pick" ]] && return
        cwd=$(print -r -- "$pick" | awk -F'\t' '{print $2}')
        uuid=$(print -r -- "$pick" | awk -F'\t' '{print $3}')
        cd -- "$cwd" || return
        claude --resume "$uuid"
      }

      _ccr_widget() {
        local pick cwd uuid
        pick=$(_ccr_pick)
        if [[ -n "$pick" ]]; then
          cwd=$(print -r -- "$pick" | awk -F'\t' '{print $2}')
          uuid=$(print -r -- "$pick" | awk -F'\t' '{print $3}')
          BUFFER="cd ''${(q)cwd} && claude --resume ''${(q)uuid}"
          zle accept-line
        else
          zle reset-prompt
        fi
      }
      zle -N _ccr_widget
      bindkey '^G' _ccr_widget
      # ----------------------------------------------------------------
    '';

    plugins = with pkgs; [
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
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
