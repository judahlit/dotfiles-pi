#!/bin/sh
# Copies the services' data to /srv/backup, where the PC fetches it. Runs every night as root,
# from pi-backup.timer. scripts/services.sh installs it as /usr/local/sbin/pi-backup, and
# scripts/restore.sh restores the copies.
set -eu
new=/srv/backup.new
rm -rf "$new"
install -d -m 700 "$new"

# Forgejo stops during the copy, so that nothing changes its database while tar reads it.
docker stop forgejo > /dev/null
trap 'docker start forgejo > /dev/null' EXIT
tar -C /srv -czf "$new/forgejo.tar.gz" forgejo
docker start forgejo > /dev/null
trap - EXIT

# Pi-hole's own export, made while it runs. It writes the file into its working folder,
# /etc/pihole, which is /srv/pihole on the Pi.
rm -f /srv/pihole/pi-hole_*_teleporter_*.zip
docker exec -w /etc/pihole pihole pihole-FTL --teleporter > /dev/null
mv /srv/pihole/pi-hole_*_teleporter_*.zip "$new/pihole-teleporter.zip"

cp /home/judah/.config/wakeonlan/pc.wol /home/judah/.ssh/authorized_keys "$new/"

# The PC logs in as judah to read the copies.
chown -R judah:judah "$new"
rm -rf /srv/backup.old
[ ! -e /srv/backup ] || mv /srv/backup /srv/backup.old
mv "$new" /srv/backup
rm -rf /srv/backup.old
