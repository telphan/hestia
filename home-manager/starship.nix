{...}:
{
   programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      format = "$directory$git_branch$elixir$lua$nix_shell$ruby$character";
      right_format = "$cmd_duration";

      directory = {
        style = "white";
        truncation_length = 1;
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };

      cmd_duration = {
        min_time = 500;
        style = "white";
        format = "[$duration]($style)";
      };

      git_branch = {
        symbol = " ";
        style = "white";
        format = "[$symbol$branch]($style) ";
      };

      nix_shell.format = "[$symbol]($style) ";

      elixir.symbol    = " ";
      lua.symbol       = "󰢱 ";
      nix_shell.symbol = " ";
      ruby.symbol      = " ";
    };
  };
}
