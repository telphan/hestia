install_nix() {
	sh <(curl -L https://nixos.org/nix/install)
}

setup_shell() {
	. ~/.nix-profile/etc/profile.d/nix.sh
}

install_home_manager() {
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
	nix-channel update
}

install_nix_darwin() {
	nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer ./result/bin/darwin-installer
	ln -sf $(pwd)/darwin-configuration/configuration.nix "${HOME}/.nixpkgs/darwin-configuration.nix"
}

install_nix
setup_shell
install_nix_darwin
install_home_manager
