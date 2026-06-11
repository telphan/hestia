{ config, lib, pkgs, ... }:
# Local MCP aggregator.
#
# Runs kfirtoledo/multi-mcp as a single long-lived SSE endpoint that fronts all
# of our *local* stdio MCP servers (semble, headroom, ...). Every AI client adds
# ONE entry pointing at http://127.0.0.1:9080/sse instead of enabling each
# backend individually; multi-mcp namespaces their tools as `server::tool`.
#
# The remote claude.ai connectors (Honeycomb, Linear, Notion, ...) are OAuth
# integrations managed in the Claude account and are intentionally NOT routed
# through here.
#
# multi-mcp has no PyPI release, so Nix pins the source for reproducibility and
# `uv` builds the env from the committed uv.lock at first launch (needs network
# once). Backends are spawned via `uvx`, so they self-fetch their packages.
let
  port = 9080;
  host = "127.0.0.1";

  # Pinned source — bump rev + sha256 together to update.
  src = pkgs.fetchFromGitHub {
    owner = "kfirtoledo";
    repo = "multi-mcp";
    rev = "07043687ee48872f7f3d56a387ddad7c4ae3ade8";
    sha256 = "1bwg7diycr98ildjfz51lprbaavgdv98aad3z38rdyi0qrxwx1vy";
  };

  # Single source of truth for the local backends behind the aggregator.
  backends = (pkgs.formats.json { }).generate "multi-mcp-servers.json" {
    mcpServers = {
      semble = {
        command = "uvx";
        args = [ "--from" "semble[mcp]" "semble" ];
      };
      headroom = {
        command = "uvx";
        args = [ "--from" "headroom-ai[all]" "headroom" "mcp" "serve" ];
      };
    };
  };

  stateDir = "${config.home.homeDirectory}/.local/state/multi-mcp";
  logFile = "${config.home.homeDirectory}/Library/Logs/multi-mcp.log";

  runner = pkgs.writeShellApplication {
    name = "multi-mcp-run";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      export UV_PROJECT_ENVIRONMENT="${stateDir}/venv"
      export UV_CACHE_DIR="${config.home.homeDirectory}/.cache/uv"
      export UV_PYTHON_INSTALL_DIR="${stateDir}/python"
      mkdir -p "${stateDir}" "$UV_CACHE_DIR"

      # uv builds the env from the pinned uv.lock (read-only store source);
      # --frozen keeps the lock untouched. main.py imports `src.*`, so it is
      # invoked by absolute path (sys.path[0] becomes the source root).
      exec uv run --frozen --project "${src}" python "${src}/main.py" \
        --transport sse \
        --host "${host}" \
        --port "${toString port}" \
        --config "${backends}" \
        --log-level INFO
    '';
  };
in
{
  home.packages = [ pkgs.uv ];

  launchd.agents.multi-mcp = {
    enable = true;
    config = {
      ProgramArguments = [ "${runner}/bin/multi-mcp-run" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      # uvx (for spawning backends) lives in the uv package; child servers
      # inherit this PATH. HOME is needed for uv/uvx caches.
      EnvironmentVariables = {
        PATH = "${pkgs.uv}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = config.home.homeDirectory;
      };
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
