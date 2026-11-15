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
4. Add the apt repositories of Tailscale and yazi:
   ```sh
   curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
   curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null
   curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg > /dev/null
   echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | sudo tee /etc/apt/sources.list.d/yazi.list > /dev/null
   ```
5. Install the packages in `packages/apt.txt`:
   ```sh
   apt-install
   ```
6. Join the tailnet. The command prints a link to log in with:
   ```sh
   sudo tailscale up
   ```

## Maintenance

After a change to `home/`, run `run-stow` to link new files. `update` upgrades the
packages.

To change the host name later, also change it in `/etc/hosts`. It must match the host
name, or `sudo` warns that it cannot resolve the host:
```sh
sudo hostnamectl set-hostname <name>
sudo sed -i 's/^127\.0\.1\.1.*/127.0.1.1 <name>/' /etc/hosts
```
