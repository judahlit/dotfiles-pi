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
   `packages/apt.txt`. One command does both:
   ```sh
   apt-install
   ```
5. Join the tailnet. The command prints a link to log in with:
   ```sh
   sudo tailscale up
   ```

## Maintenance

After a change to `home/`, run `run-stow` to link new files. `update` upgrades the
packages.

`apt-install` also removes what was deleted from the two lists since its last run: a
repository at once, and a package unless another package needs it. It keeps a record of
each run in `~/.local/state/dotfiles-pi/`. Without a record, it removes nothing.

To change the host name later, also change it in `/etc/hosts`. It must match the host
name, or `sudo` warns that it cannot resolve the host:
```sh
sudo hostnamectl set-hostname <name>
sudo sed -i 's/^127\.0\.1\.1.*/127.0.1.1 <name>/' /etc/hosts
```
