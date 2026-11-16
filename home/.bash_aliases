alias aliases='$EDITOR "$HOME/dotfiles-pi/home/.bash_aliases"'

# quick cd
alias dotfiles='cd ~/dotfiles-pi'

# common commands
alias run-stow='stow --no-folding -d "$HOME/dotfiles-pi/" -t ~ home'

# packages
alias update='~/dotfiles-pi/scripts/update.sh'
alias apt-install='~/dotfiles-pi/scripts/apt.sh'
alias apt-list='$EDITOR "$HOME/dotfiles-pi/packages/apt.txt"'
alias apt-sources-list='$EDITOR "$HOME/dotfiles-pi/packages/apt-sources.txt"'
