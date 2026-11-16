#!/bin/sh
# Installs the packages in packages/apt.txt. A package deleted from the list since the last
# run becomes automatically installed, so autoremove removes it unless another package needs
# it.
set -e
cd "$(dirname "$0")/.."
state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-pi"
names() {
	sed 's/#.*//' "$1" | tr -s ' \t' '\n' | sed '/^$/d' | LC_ALL=C sort -u
}
packages=$(names packages/apt.txt)

scripts/apt-sources.sh
sudo apt-get update
sudo apt-get install --no-install-recommends $packages

if [ ! -e "$state/apt.txt" ]; then
	echo "No record of an earlier run: this run removes nothing."
else
	delisted=$(echo "$packages" | LC_ALL=C comm -13 - "$state/apt.txt")
	if [ -n "$delisted" ]; then
		manual=$(apt-mark showmanual | grep -Fx "$delisted" || true)
		[ -z "$manual" ] || sudo apt-mark auto $manual
		sudo apt-get autoremove
		kept=$(apt-mark showauto | grep -Fx "$delisted" || true)
		[ -z "$kept" ] || echo "Kept, because other packages need them:" $kept
	fi
fi

mkdir -p "$state"
echo "$packages" > "$state/apt.txt"
