{ lib, ... }:
{
  home.activation.karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
    if [ -x "$karabiner_cli" ]; then
      launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server" 2>/dev/null || true
      sleep 1
    fi
    mkdir -p "$HOME/.config/karabiner"
    cp -f ${./config/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
    chmod 600 "$HOME/.config/karabiner/karabiner.json"
    if [ -x "$karabiner_cli" ]; then
      launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server" 2>/dev/null || true
    fi
  '';
}
