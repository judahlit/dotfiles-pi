#!/bin/sh
# Restores a nightly copy from scripts/backup.sh on a fresh install, then starts the services.
# The README's "Restore on a fresh install" says when to run it.
set -eu
[ $# -eq 1 ] || { echo "Usage: $0 <folder with the nightly copy>" >&2; exit 1; }
from=$(realpath "$1")
cd "$(dirname "$0")"

if [ -e /srv/forgejo ]; then
	echo "/srv/forgejo exists. This script never unpacks over existing data." >&2
	exit 1
fi
for file in forgejo.tar.gz pihole-teleporter.zip pc.wol authorized_keys; do
	[ -e "$from/$file" ] || { echo "$from/$file is missing." >&2; exit 1; }
done

# Before services.sh, so that Forgejo starts with its old data and secret key.
sudo tar -C /srv -xzf "$from/forgejo.tar.gz"
./services.sh

# Pi-hole reads the imported settings at its next start.
sudo docker cp "$from/pihole-teleporter.zip" pihole:/tmp/
sudo docker exec pihole pihole-FTL --teleporter /tmp/pihole-teleporter.zip
sudo docker exec pihole rm /tmp/pihole-teleporter.zip
sudo docker restart pihole > /dev/null

install -D -m 644 "$from/pc.wol" ~/.config/wakeonlan/pc.wol
install -m 600 "$from/authorized_keys" ~/.ssh/authorized_keys
echo "Restored. Next: install step 8, with the new Pi's address."
