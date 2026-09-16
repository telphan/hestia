{ lib, stdenvNoCC, source, python3, asciidoctor, complgen, installShellFiles }:
let
  # SwiftPM's lock file pins every dependency to a commit. Fetch those trees
  # through Nix, then use local packages so compilation needs no network.
  pins = (builtins.fromJSON (builtins.readFile "${source}/Package.resolved")).pins;
  dependencies = map (pin: let
    repository = lib.splitString "/" (lib.removePrefix "https://github.com/" (lib.removeSuffix ".git" pin.location));
    tree = builtins.fetchTree {
      type = "github";
      owner = builtins.elemAt repository 0;
      repo = builtins.elemAt repository 1;
      rev = pin.state.revision;
    };
  in {
    inherit (pin) identity location;
    path = builtins.path {
      path = tree.outPath;
      name = pin.identity;
    };
  }) pins;
  dependencyManifest = builtins.toFile "aerospace-dependencies.json" (builtins.toJSON dependencies);
  revision = source.rev;
  version = "0.0.0-unstable-${builtins.substring 0 8 source.lastModifiedDate}-${builtins.substring 0 7 revision}";
in
stdenvNoCC.mkDerivation {
  pname = "aerospace";
  inherit version;
  src = source;

  nativeBuildInputs = [ python3 asciidoctor complgen installShellFiles ];

  # nixpkgs' Swift is too old for upstream main. Use the local Apple Command
  # Line Tools (Swift >= 6.2) with Darwin's default sandbox = false. The source
  # and dependencies are pinned, but the host compiler/SDK are not managed by Nix.
  dontFixup = true; # Do not modify the binaries after code signing.

  postPatch = ''
    python3 - ${dependencyManifest} <<'PY'
    import json
    import pathlib
    import re
    import shutil
    import sys

    manifest = pathlib.Path("Package.swift")
    text = manifest.read_text()
    for dependency in json.load(open(sys.argv[1])):
        destination = pathlib.Path("deps") / dependency["identity"]
        shutil.copytree(dependency["path"], destination)
        pattern = r'\.package\(url: "' + re.escape(dependency["location"]) + r'(?:\.git)?", exact: "[^"]+"\)'
        text, count = re.subn(pattern, '.package(path: "' + str(destination) + '")', text)
        if count != 1:
            raise SystemExit("Update the package rewrite for " + dependency["identity"])
    manifest.write_text(text)
    pathlib.Path("Package.resolved").unlink()
    PY

    cat > Sources/Common/versionGenerated.swift <<'EOF'
    public let aeroSpaceAppVersion = "${version}"
    EOF
    cat > Sources/Common/gitHashGenerated.swift <<'EOF'
    public let gitHash = "${revision}"
    public let gitShortHash = "${builtins.substring 0 7 revision}"
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    export SDKROOT="$DEVELOPER_DIR/SDKs/MacOSX.sdk"
    export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
    export SWIFTPM_MODULECACHE_OVERRIDE="$TMPDIR/swift-module-cache"

    "$DEVELOPER_DIR/usr/bin/swift" --version
    "$DEVELOPER_DIR/usr/bin/swift" build -c release --disable-sandbox --jobs "$NIX_BUILD_CORES" \
      --cache-path "$TMPDIR/swift-cache" \
      --config-path "$TMPDIR/swift-config" \
      --security-path "$TMPDIR/swift-security"

    mkdir -p manpage shell-completion
    asciidoctor -b manpage -D manpage docs/aerospace*.adoc
    complgen grammar/commands-bnf-grammar.txt --bash shell-completion/aerospace.bash
    complgen grammar/commands-bnf-grammar.txt --fish shell-completion/aerospace.fish
    complgen grammar/commands-bnf-grammar.txt --zsh shell-completion/_aerospace

    mkdir AppIcon.iconset
    for iconSize in 16 32 128 256 512; do
      /usr/bin/sips -z "$iconSize" "$iconSize" resources/Assets.xcassets/AppIcon.appiconset/icon.png \
        --out "AppIcon.iconset/icon_''${iconSize}x''${iconSize}.png" >/dev/null
      retinaSize=$((iconSize * 2))
      /usr/bin/sips -z "$retinaSize" "$retinaSize" resources/Assets.xcassets/AppIcon.appiconset/icon.png \
        --out "AppIcon.iconset/icon_''${iconSize}x''${iconSize}@2x.png" >/dev/null
    done
    /usr/bin/iconutil -c icns AppIcon.iconset
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    app="$out/Applications/AeroSpace.app/Contents"
    mkdir -p "$app/MacOS" "$app/Resources" "$out/bin"
    cp .build/release/AeroSpaceApp "$app/MacOS/AeroSpace"
    cp .build/release/aerospace "$out/bin/aerospace"
    cp docs/config-examples/default-config.toml "$app/Resources/"
    cp AppIcon.icns "$app/Resources/"
    cat > "$app/Info.plist" <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
      <key>CFBundleExecutable</key><string>AeroSpace</string>
      <key>CFBundleIdentifier</key><string>bobko.aerospace</string>
      <key>CFBundleName</key><string>AeroSpace</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${version}</string>
      <key>CFBundleVersion</key><string>${builtins.substring 0 8 source.lastModifiedDate}</string>
      <key>CFBundleIconFile</key><string>AppIcon</string>
      <key>LSMinimumSystemVersion</key><string>13.0</string>
      <key>LSUIElement</key><true/>
      <key>NSHighResolutionCapable</key><true/>
    </dict></plist>
    EOF
    printf 'APPL????' > "$app/PkgInfo"
    /usr/bin/codesign --force --sign - --entitlements resources/AeroSpace.entitlements "$out/Applications/AeroSpace.app"
    /usr/bin/codesign --force --sign - "$out/bin/aerospace"
    installManPage manpage/*.1
    installShellCompletion --cmd aerospace --bash shell-completion/aerospace.bash
    installShellCompletion --fish shell-completion/aerospace.fish
    installShellCompletion --zsh shell-completion/_aerospace
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/aerospace" --version | grep -F '${version} ${revision}'
    /usr/bin/plutil -lint "$out/Applications/AeroSpace.app/Contents/Info.plist"
    /usr/bin/codesign --verify --deep --strict "$out/Applications/AeroSpace.app"
    /usr/bin/codesign --verify --strict "$out/bin/aerospace"
    runHook postInstallCheck
  '';

  meta = {
    description = "i3-like tiling window manager for macOS, pinned to upstream main";
    homepage = "https://github.com/nikitabobko/AeroSpace";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "aerospace";
  };
}
