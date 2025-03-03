{ user, ... }:
{
  home.file."/Users/${user}/.config/karabiner/karabiner.json".source = ./config/karabiner.json;
}
