{ config, lib, pkgs, ... }:
# Local MCP aggregator.
#
# Runs kfirtoledo/multi-mcp as a single long-lived SSE endpoint that fronts our
# project-agnostic *local* stdio MCP servers (semble, headroom). Every AI client
# adds
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
      # NOTE: serena is deliberately NOT fronted here. As a shared aggregator
      # backend it runs projectless with a fixed cwd of `/`, so its language
      # servers (and their pre-flight probes, e.g. `elixir --version`) resolve
      # asdf shims from `/` — where no `.tool-versions` applies — and fail even
      # though the toolchain is installed. serena is instead registered directly
      # in each client with `--project-from-cwd`, so its cwd is the repo and each
      # project's own `.tool-versions` is honoured. See the client MCP configs.
    };
  };

  stateDir = "${config.home.homeDirectory}/.local/state/multi-mcp";
  logFile = "${config.home.homeDirectory}/Library/Logs/multi-mcp.log";

  # multi-mcp declares its deps in requirements.txt (NOT pyproject.toml), so we
  # build a venv and `uv pip install -r requirements.txt` into it — mirroring the
  # project's own `uv venv && uv pip install -r requirements.txt` workflow.
  # `uv run` would produce an empty env (pyproject has no dependencies).
  runner = pkgs.writeShellApplication {
    name = "multi-mcp-run";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      export UV_CACHE_DIR="${config.home.homeDirectory}/.cache/uv"

      # Venv is keyed to the pinned source rev, so bumping `src` rebuilds it.
      # requirements.txt needs Python >=3.10; macOS ships 3.9, so pin a
      # uv-managed 3.12 (auto-downloaded once).
      venv="${stateDir}/venv-${src.rev}"
      if [ ! -x "$venv/bin/python" ]; then
        mkdir -p "${stateDir}" "$UV_CACHE_DIR"
        uv venv --python 3.12 "$venv"
        uv pip install --python "$venv/bin/python" -r "${src}/requirements.txt"
      fi

      # main.py imports `src.*`, so it is invoked by absolute path
      # (sys.path[0] becomes the source root).
      exec "$venv/bin/python" "${src}/main.py" \
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

  # Work around a teardown race in home-manager's launchd activation.
  #
  # When this plist changes, HM reloads the agent as: bootout -> `sleep 1` ->
  # bootstrap. But multi-mcp fans out into a whole tree of child processes
  # (uv -> python -> semble/headroom/serena, plus serena's project-server), and
  # tearing that down takes longer than the fixed 1s. bootstrap then fires while
  # the old job is still registered, which launchd rejects with
  # "Bootstrap failed: 5: Input/output error" and the agent is left down.
  #
  # This hook runs BEFORE HM's setupLaunchAgents and, ONLY when the plist is
  # actually going to be reloaded (mirroring HM's own `cmp` gate so we never
  # stop an agent that HM would otherwise leave running), boots the agent out
  # and polls until launchd has fully removed it. HM then bootstraps into a
  # clean domain.
  home.activation.stopMultiMcpForReload =
    lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
      mmAgent="org.nix-community.home.multi-mcp"
      mmInstalled="${config.home.homeDirectory}/Library/LaunchAgents/$mmAgent.plist"
      mmStaged="$(readlink -m "$newGenPath/LaunchAgents/$mmAgent.plist")"
      mmDomain="gui/$UID"

      if [[ -e "$mmInstalled" && -e "$mmStaged" ]] && ! cmp -s "$mmStaged" "$mmInstalled"; then
        verboseEcho "multi-mcp plist changed; stopping agent before reload"
        run /bin/launchctl bootout "$mmDomain/$mmAgent" 2>/dev/null || true
        # Poll up to ~10s for launchd to fully unload the (child-heavy) job.
        for _ in $(seq 1 50); do
          /bin/launchctl print "$mmDomain/$mmAgent" >/dev/null 2>&1 || break
          /bin/sleep 0.2
        done
      fi
    '';

  launchd.agents.multi-mcp = {
    enable = true;
    config = {
      ProgramArguments = [ "${runner}/bin/multi-mcp-run" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      # uvx (for spawning backends) lives in the uv package; child servers
      # inherit this PATH. HOME is needed for uv/uvx caches. The remaining
      # backends (semble, headroom) are pure Python tools and need no asdf/
      # toolchain shims — those left with serena (see the backends note above).
      EnvironmentVariables = {
        PATH = "${pkgs.uv}/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = config.home.homeDirectory;
      };
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
