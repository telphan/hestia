HERE=$( cd "$(dirname "$0")" ; pwd -P )
darwin-rebuild $@ -I "darwin-config=${HERE}/../darwin-configuration.nix"
