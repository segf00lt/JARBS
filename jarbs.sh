#!/bin/sh

# joao's auto ricing and bootstrapping script

username=`whoami`
doturl='https://github.com/segf00lt/dotfiles'
dotrepodir="${doturl%%*/}"

error() {
	printf "jarbs: %s\n" "$1" 1>&2 && exit 1
}

pminstall() {
	sudo pacman --noconfirm --needed -S
}

aurinstall() {
	yay --noconfirm --needed -S
}

gitmakeinstall() {
	pushd /tmp
	git clone "$1"
	cd "${1##*/}"
	make
	sudo make install
	popd
}

# update system, install git and yay
sudo pacman --noconfirm --needed -Syu
pushd /tmp
pminstall base-devel git
git clone https://aur.archlinux.org/yay.git
sudo chown -R "$username:users" ./yay
cd yay
makepkg -Asi
popd

# install progs
while IFS=, read -r tag prog; do
	case "$tag" in
		"A") aurinstall prog ;;
		"G") gitmakeinstall prog ;;
		*) pminstall prog ;;
	esac
done < progs.csv

# download and install dotfiles
pushd "$HOME"
git clone --recursive "$dotfiles"
cd "$dotrepodir"
mv -fv * ..
cd ..
mv -fv "$dotrepodir" '.config'
popd

echo "All done!"
