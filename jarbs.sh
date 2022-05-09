#!/bin/sh

# joao's auto ricing and bootstrapping script

username=`whoami`
loginshell='/usr/bin/zsh'
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
	chsh -s "$loginshell" "$username"
}

[[ $# == 0 || "${1##*.}" != csv ]] && error 'no csv file given'
progsfile="$1"

# update system, install git and yay
update
pminstall git
if [[ ! -f /usr/bin/yay ]]; then
	pushd /tmp
	git clone https://aur.archlinux.org/yay.git
	sudo chown -R "$username:users" ./yay
	cd yay
	makepkg -Asi
	popd
fi

# download and install dotfiles
pushd "/home/$username"
git clone --recursive "$dotfiles"
cd "$dotrepodir"
cd ..
cp -rf "$dotrepodir/*" .
popd

# TODO extract repo progs and install in single pacman command
# install progs
while IFS=, read -r tag prog; do
	case "$tag" in
		"A") aurinstall "$prog" ;;
		"G") gitmakeinstall "$prog" ;;
		*) pminstall "$prog" ;;
	esac
done < "$progsfile"

changeshell

echo "All done!"
