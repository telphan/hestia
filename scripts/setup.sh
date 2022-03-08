HERE=$( cd "$(dirname "$0")" ; pwd -P )
install_nix() {
	sh <$(curl -L https://nixos.org/nix/install)
}

setup_home_manager() {
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
	nix-channel update
}

install_nix_darwin() {
	nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
        ./result/bin/darwin-installer
}

install_brew() {
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

which nix &>/dev/null || ( install_nix && setup_home_manager )
which brew &>/dev/null || install_brew
which darwin-rebuild &>/dev/null || ( install_nix_darwin && exit 0 )

${HERE}/build-darwin.sh switch
