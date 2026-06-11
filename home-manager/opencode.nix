{ config, lib, pkgs, ... }:
# opencode — installed to self-update, NOT via nixpkgs.
#
# opencode disables its own autoupdate when installed through a package manager
# (the read-only Nix store can't be written to). Since we want it auto-updating,
# we install it via opencode's native installer into ~/.opencode/bin, where its
# built-in autoupdate (on by default, runs at startup) keeps it current.
#
# Nix's role is limited to: (1) putting ~/.opencode/bin on PATH declaratively,
# and (2) a one-time bootstrap so a fresh machine gets opencode on first switch.
# After that, opencode updates itself — the installed version is intentionally
# NOT pinned in this repo (that's the trade for "auto-updatable").
#
# To pin instead: delete this module and add `opencode` to home.packages.
let
  binDir = "${config.home.homeDirectory}/.opencode/bin";
in
{
  # Declarative PATH entry. Having binDir on PATH before the installer runs also
  # makes the installer skip editing shell rc files (which Nix manages).
  home.sessionPath = [ binDir ];

  # One-time bootstrap: only runs when opencode is absent. Updates are opencode's
  # job from then on, so we deliberately don't re-run the installer every switch.
  home.activation.opencodeBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "${binDir}/opencode" ]; then
      echo "Bootstrapping opencode into ${binDir} (one-time; it self-updates thereafter)…"
      run ${pkgs.bash}/bin/bash -c 'export PATH="${binDir}:${pkgs.curl}/bin:/usr/bin:/bin"; ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install | bash' \
        || echo "opencode bootstrap failed (offline?) — will retry on next switch."
    fi
  '';
}
