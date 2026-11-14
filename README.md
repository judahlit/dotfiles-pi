# dotfiles-pi

The setup of the home Raspberry Pi 4: package lists and config files, linked into the home
folder with GNU Stow. The Pi runs Raspberry Pi OS Lite (64-bit), which is based on Debian 13.

## Install

Run these on the Pi, logged in with SSH.

1. Install git, and clone this repository:
   ```sh
   sudo apt update && sudo apt install git
   git clone https://github.com/judahlit/dotfiles-pi.git ~/dotfiles-pi
   ```
2. Add the apt repositories of Tailscale and yazi, which are not in Debian:
   ```sh
   curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
   curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null
   curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg > /dev/null
   echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | sudo tee /etc/apt/sources.list.d/yazi.list > /dev/null
   ```
3. Install the packages in `packages/apt.txt`:
   ```sh
   ~/dotfiles-pi/scripts/apt.sh
   ```
4. Link the config files. Stow does not replace a file that already exists, so first
   remove the default `~/.profile`, which `home/.profile` replaces:
   ```sh
   rm ~/.profile
   stow --no-folding -d ~/dotfiles-pi -t ~ home
   ```
5. Join the tailnet. The command prints a link to log in with:
   ```sh
   sudo tailscale up
   ```

After a change to `home/`, run `run-stow` to link new files. `update` upgrades the
packages.
