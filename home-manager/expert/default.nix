{ config, pkgs, lib, ... }:

let
  # Expert version - update this when a new version is released
  version = "main"; # or use a specific commit/tag
  
  # Zig 0.14.1 specifically required (not latest)
  zig_0_14_1 = pkgs.zig_0_14;

  # Create the Expert package by building from source
  expert = pkgs.stdenv.mkDerivation rec {
    pname = "expert";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "elixir-lang";
      repo = "expert";
      rev = version; # or use a specific commit hash
      sha256 = ""; # Replace with actual SHA256 hash
      fetchLFS = true; # Required for git LFS files
    };

    nativeBuildInputs = with pkgs; [
      # Build tools
      git
      git-lfs
      just
      zig_0_14_1
      
      # Elixir and Erlang - use versions that meet Expert's requirements
      elixir
      erlang
      
      # Additional utilities
      gnumake
      gcc
    ];

    buildInputs = with pkgs; [
      elixir
      erlang
    ];

    # Set up git LFS and other environment
    preBuild = ''
      export HOME=$TMPDIR
      git config --global user.email "nix-build@example.com"
      git config --global user.name "Nix Build"
      
      # Initialize git LFS
      git lfs install
      
      # Ensure Zig is the correct version
      zig version
    '';

    buildPhase = ''
      runHook preBuild
      
      # Follow the build steps from installation.md
      just deps forge
      just deps engine  
      just deps expert
      
      # Build the release
      just release-local
      
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      
      # Create output directory
      mkdir -p $out/bin
      
      # Find and copy the correct binary based on platform
     if [[ "$system" == "x86_64-darwin" ]]; then
        cp apps/expert/burrito_out/expert_darwin_amd64 $out/bin/expert
      elif [[ "$system" == "aarch64-darwin" ]]; then
        cp apps/expert/burrito_out/expert_darwin_arm64 $out/bin/expert
      else
        echo "Unsupported system: $system"
        exit 1
      fi
      
      # Ensure binary is executable
      chmod +x $out/bin/expert
      
      runHook postInstall
    '';

    # Skip tests for now (can be enabled if needed)
    doCheck = false;

    meta = with lib; {
      description = "Official Language Server Protocol implementation for Elixir";
      longDescription = ''
        Expert is the official language server implementation for the Elixir 
        programming language. It provides IDE features like auto-completion,
        go-to-definition, diagnostics, and more via the Language Server Protocol.
        
        Supports Elixir 1.15.3+ with Erlang 25.0+.
      '';
      homepage = "https://github.com/elixir-lang/expert";
      changelog = "https://github.com/elixir-lang/expert/releases";
      license = licenses.asl20;
      maintainers = [ ];
      platforms = [ "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "expert";
    };
  };

in
{
  # Install Expert as a user package
  home.packages = [ expert ];

  # Optional: Add configuration for popular editors
  programs = {
    # For users of VS Code/VSCodium
    vscode = lib.mkIf config.programs.vscode.enable {
      extensions = with pkgs.vscode-extensions; [
        # Add Lexical extension if available, or configure manually
      ];
      userSettings = {
        # Configure Lexical extension to use Expert
        "lexical.server.releasePathOverride" = "${expert}/bin/expert";
      };
    };
  };

  # Optional: Shell aliases and environment
  home.shellAliases = {
    expert-version = "${expert}/bin/expert --version";
    expert-help = "${expert}/bin/expert --help";
  };

  # Optional: Add to PATH explicitly (though home.packages should handle this)
  home.sessionPath = [ "${expert}/bin" ];
}
