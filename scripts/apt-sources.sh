#!/bin/sh
# Adds the repositories in packages/apt-sources.txt, and removes the ones deleted from it since
# the last run.
set -e
cd "$(dirname "$0")/.."
state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-pi"
sources=$(sed 's/#.*//; /^[[:space:]]*$/d' packages/apt-sources.txt)

keyring() {
	echo "$1" | sed 's/.*signed-by=\([^] ]*\).*/\1/'
}

echo "$sources" | while read -r name key source; do
	[ -n "$name" ] || continue
	case "$source" in
	*signed-by=*) ;;
	*) echo "The source line of $name has no signed-by." >&2; exit 1 ;;
	esac
	# Download the key only once: a keyring package, such as tailscale-archive-keyring,
	# replaces the file with newer keys.
	[ -e "$(keyring "$source")" ] || sudo curl -fsSL -o "$(keyring "$source")" "$key"
	echo "$source" | sudo tee "/etc/apt/sources.list.d/$name.list" > /dev/null
done

if [ -e "$state/apt-sources.txt" ]; then
	names=$(echo "$sources" | awk '{ print $1 }')
	while read -r name key source; do
		echo "$names" | grep -qFx "$name" && continue
		sudo rm -f "/etc/apt/sources.list.d/$name.list"
		dpkg -S "$(keyring "$source")" > /dev/null 2>&1 || sudo rm -f "$(keyring "$source")"
	done < "$state/apt-sources.txt"
fi

mkdir -p "$state"
echo "$sources" > "$state/apt-sources.txt"
