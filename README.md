# hestia
Home Sweet Home

## AeroSpace main-branch pin

AeroSpace follows upstream `main` through the `aerospace-src` flake input.
`flake.lock` pins the exact commit; rebuilding does not automatically advance it.
The Darwin overlay builds both the app and CLI from that source, using the Swift
dependency commits in upstream's `Package.resolved`.

The build uses Apple's Command Line Tools at
`/Library/Developer/CommandLineTools` (Swift 6.2 or newer) and Darwin Nix's default
`sandbox = false`. Full Xcode is not required. The source and dependencies are
pinned, but the host compiler and macOS SDK are outside the Nix pin.

Update only AeroSpace and check the resulting package:

```sh
nix flake update aerospace-src
nix build .#darwinConfigurations.Theodors-MacBook-Pro.pkgs.aerospace
./result/Applications/AeroSpace.app/Contents/MacOS/AeroSpace --version
```

Apply the configuration:

```sh
sudo darwin-rebuild switch --flake .#Theodors-MacBook-Pro
```

The app and CLI must be updated together. Restart AeroSpace if the CLI reports
an incompatible client/server protocol after switching.

Keep `flake.nix`, `flake.lock`, and `darwin/aerospace.nix` in Git. Commit the
updated lock file after advancing AeroSpace. To return to an earlier revision,
restore its `aerospace-src` lock entry from Git and rebuild.

## SketchyBar recovery after activation

On 2026-09-16, SketchyBar's launch agent was running after an upgrade, but the
bar had no items and reported `drawing: off`. Reloading the configuration restored
it, and a clean service restart also passed. AeroSpace workspace highlighting
and the CPU, memory, and network helpers worked afterward. The cause of the empty
configuration was not established; no permanent SketchyBar configuration change
was needed.

If the bar is missing after a rebuild, inspect it and reload its configuration:

```sh
launchctl print "gui/$(id -u)/org.nixos.sketchybar"
sketchybar --query bar
sketchybar --reload
```

If a reload does not restore it, restart the user service:

```sh
launchctl kickstart -k "gui/$(id -u)/org.nixos.sketchybar"
```

Check `sketchybar --query bar` again after startup: it should report `drawing: on`
and a populated `items` list. These recovery commands run as the logged-in user.
If this recurs, capture the Lua startup error and investigate the three
`onChange` reload hooks in `home-manager/sketchybar/default.nix` before changing
package pins or service settings.
