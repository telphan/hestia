{ config, lib, pkgs, ... }:
# Standalone CLIs for our local AI tools, installed as uv tools so the `semble`
# and `headroom` commands live on PATH (~/.local/bin, already on PATH via
# shell.nix). These are the same packages the multi-mcp aggregator fronts
# (see ./multi-mcp.nix), installed here for direct shell use.
#
# `uv tool install` is idempotent: it no-ops when the tool is already present,
# so this is cheap on every switch. Nothing is pinned — to refresh, run
# `uv tool upgrade --all`.
let
  # macOS ships Python 3.9; these all require newer, so each pins a uv-managed
  # interpreter (auto-downloaded once) rather than letting uv pick the system one.
  uvTools = [
    { pkg = "semble[mcp]"; python = "3.12"; }      # code search → `semble`
    { pkg = "headroom-ai[all]"; python = "3.12"; } # context compression → `headroom`
    { pkg = "serena-agent"; python = "3.13"; }     # LSP symbol tools + CLI → `serena`
  ];
  uv = "${pkgs.uv}/bin/uv";
in
{
  home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.uv}/bin:$PATH"
    ${lib.concatMapStringsSep "\n" (t:
      ''run ${uv} tool install --quiet --python ${t.python} "${t.pkg}" || echo "uv tool install ${t.pkg} failed (offline?) — will retry next switch."''
    ) uvTools}
  '';
}
