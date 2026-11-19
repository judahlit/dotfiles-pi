# dotfiles-pi

The setup of the home Raspberry Pi 4: package lists and config files, linked into the home
folder with GNU Stow. The Pi runs Raspberry Pi OS Lite (64-bit), which is based on Debian 13.

## Install

1. Write Raspberry Pi OS Lite (64-bit) to the card with Raspberry Pi Imager. In its
   settings, set the host name `pi`, the user `judah` with an SSH key and no password
   login, and the Wi-Fi network.
2. Start the Pi, and log in with SSH. Imager's settings reach the Pi through cloud-init,
   which applies them again at each boot and would undo later changes. Turn it off:
   ```sh
   sudo touch /etc/cloud/cloud-init.disabled
   ```
3. Install git and stow, clone this repository, and link the config files. Stow does not
   replace a file that already exists, so first remove the default `~/.profile`, which
   `home/.profile` replaces. `exec bash` then starts a shell that reads the linked files,
   so the aliases below work:
   ```sh
   sudo apt update && sudo apt install git stow
   git clone https://github.com/judahlit/dotfiles-pi.git ~/dotfiles-pi
   rm ~/.profile
   stow --no-folding -d ~/dotfiles-pi -t ~ home
   exec bash
   ```
4. Add the apt repositories in `packages/apt-sources.txt` and install the packages in
   `packages/apt.txt`, Docker among them. One command does both:
   ```sh
   apt-install
   ```
5. Join the tailnet. The command prints a link to log in with:
   ```sh
   sudo tailscale up
   ```
6. Start the services in `compose/`: Pi-hole, the DNS server that blocks ads, and Forgejo,
   the git server. First, in the Tailscale admin console, open DNS and turn on HTTPS
   Certificates: Tailscale Serve needs them to publish the web pages over HTTPS. Then:
   ```sh
   services-up
   ```
   It creates Forgejo's secret key, starts the containers, and publishes them with Tailscale
   Serve. It also installs a timer that copies their data to `/srv/backup` every night at
   04:00. The aliases `pihole` and `forgejo` run those commands inside their containers.
   Forgejo is then at `https://pi.tail87bfdc.ts.net/`, and Pi-hole's web page at
   `https://pi.tail87bfdc.ts.net:8443/admin/`.
7. Set the password of Pi-hole's web page:
   ```sh
   pihole setpassword
   ```
8. Make Pi-hole the tailnet's DNS server. First, stop the Pi from sending its own lookups
   to the tailnet's DNS, which would be Pi-hole again:
   ```sh
   sudo tailscale set --accept-dns=false
   ```
   In the Tailscale admin console, open DNS. Add a custom nameserver with the Pi's address
   from `tailscale ip -4`, and turn on "Override DNS servers". To test, run
   `dig +short doubleclick.net` on another tailnet device. It prints `0.0.0.0`.
9. Create your Forgejo account as the administrator. The command prints a password to log in
   with:
   ```sh
   forgejo admin user create --admin --username judah --email <email> --random-password
   ```
   On the web page, change the password, and add your SSH public key under Settings, SSH /
   GPG keys. Forgejo's SSH server uses port 2222. On the laptop, an entry in
   `~/.ssh/config` hides the port, so clone addresses become `forge:judah/<repo>.git`:
   ```
   Host forge
       HostName pi.tail87bfdc.ts.net
       Port 2222
       User git
   ```
   To test, run `ssh -T forge` on the laptop. Forgejo answers with a greeting.
10. Let the PC fetch the nightly copies. The PC uses its own key without a passphrase, so
    limit that key to reading `/srv/backup`. Add this line to `~/.ssh/authorized_keys` on the
    Pi, as one line. Replace `<the PC's key>` with the text of `~/.ssh/pi-backup.pub` on
    the PC:
    ```
    command="rrsync -ro /srv/backup",restrict <the PC's key>
    ```

## Maintenance

After a change to `home/`, run `run-stow` to link new files. `update` upgrades the
apt packages, but not the containers.

Each service in `compose/` has its settings in its `compose.yaml`, and its data in
`/srv/<service>`. `scripts/backup.sh` says how to restore the nightly copy of that data.
`services-up` updates the services to their newest images, and applies a change to a
`compose.yaml`. Forgejo follows its LTS series, with security fixes until
15 July 2027. Before that date, change its image tag in `compose/forgejo/compose.yaml` to
the next LTS series on [its release page](https://codeberg.org/forgejo/forgejo/releases).

`apt-install` also removes what was deleted from the two lists since its last run: a
repository at once, and a package unless another package needs it. It keeps a record of
each run in `~/.local/state/dotfiles-pi/`. Without a record, it removes nothing.

To change the host name later, also change it in `/etc/hosts`. It must match the host
name, or `sudo` warns that it cannot resolve the host:
```sh
sudo hostnamectl set-hostname <name>
sudo sed -i 's/^127\.0\.1\.1.*/127.0.1.1 <name>/' /etc/hosts
```
