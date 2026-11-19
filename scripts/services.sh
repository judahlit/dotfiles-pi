#!/bin/sh
# Starts the services in compose/, or updates them to their newest images. Then publishes
# Forgejo and Pi-hole's web page to the tailnet with Tailscale Serve. Run it again after a
# change in compose/.
set -eu
cd "$(dirname "$0")/../compose"

# Forgejo runs as user 1000, and Docker would create a missing folder as root.
sudo install -d -o 1000 -g 1000 -m 700 /srv/forgejo
# Without a secret key, Forgejo uses a fixed one that is in its public source code.
if ! sudo test -s /srv/forgejo/secret_key; then
	key=$(openssl rand -hex 32)
	echo "$key" | sudo install -o 1000 -g 1000 -m 600 /dev/stdin /srv/forgejo/secret_key
fi

for service in */; do
	sudo docker compose -f "${service}compose.yaml" up -d --pull always --remove-orphans
done
# Removes the images that the updates replaced.
sudo docker image prune -f

sudo tailscale serve --bg --https=443 http://127.0.0.1:3000
sudo tailscale serve --bg --tcp=2222 tcp://127.0.0.1:2222
sudo tailscale serve --bg --https=8443 http://127.0.0.1:8080
