#!/bin/sh

# joao's auto ricing and bootstrapping script

username=`whoami`
loginshell=zsh
doturl='https://github.com/segf00lt/dotfiles'
dotrepodir="${doturl%%*/}"

error() {
	printf "jarbs: %s\n" "$1" 1>&2 && exit 1
}

update() {
	sudo pacman --noconfirm --needed -Syu
}

pminstall() {
	sudo pacman --noconfirm --needed -S $@
}

aurinstall() {
	yay --noconfirm --needed -S $@
}

gitmakeinstall() {
	pushd /tmp
	git clone "$1"
	cd "${1##*/}"
	make
	sudo make install
	popd
}

changeshell() {
	sudo chsh -s "$loginshell" "$username"
}

[[ $# == 0 || "${1##*.}" != csv ]] && error 'no csv file given'
progsfile="$1"

# update system, install git and yay
update
pushd /tmp
pminstall git
git clone https://aur.archlinux.org/yay.git
sudo chown -R "$username:users" ./yay
cd yay
makepkg -Asi
popd

# download and install dotfiles
pushd "$HOME"
git clone --recursive "$dotfiles"
cd "$dotrepodir"
mv -fv * ..
mv -fv . "$HOME/.config"
popd

# install progs
while IFS=, read -r tag prog; do
	case "$tag" in
		"A") aurinstall prog ;;
		"G") gitmakeinstall prog ;;
		*) pminstall prog ;;
	esac
done < "$progsfile"

changeshell

echo "All done!"
