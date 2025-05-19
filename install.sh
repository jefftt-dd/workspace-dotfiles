#!/usr/bin/env bash

set -exuo pipefail

sudo add-apt-repository -y ppa:neovim-ppa/unstable && sudo apt update

sudo apt install -y neovim \
  libevent-dev ncurses-dev ncurses-dev build-essential bison pkg-config # tmux dev dependencies

# Symlink dotfiles to the root within your workspace
DOTFILES_PATH="$HOME/dotfiles"
find $DOTFILES_PATH -type f -path "$DOTFILES_PATH/.*" |
while read df; do
  link=${df/$DOTFILES_PATH/$HOME}
  mkdir -p "$(dirname "$link")"
  ln -sf "$df" "$link"
done

#### Neovim
# https://github.com/junegunn/vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim

#### Tmux
wget https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
tar xzvf tmux-3.5a.tar.gz
cd tmux-3.5a
./configure
make && sudo make install
cd ..
rm -rf tmux-3.5a.tar.gz tmux-3.5a

#### Fish Shell (already installed)

# https://github.com/sharkdp/fd
curl -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb > fd_10.2.0_amd64.deb
sudo dpkg -i fd_10.2.0_amd64.deb
ln -sf $(which fdfind) ~/.local/bin/fd
rm -f fd_10.2.0_amd64.deb

# https://github.com/sharkdp/bat
curl -L https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb > bat_0.25.0_amd64.deb
sudo dpkg -i bat_0.25.0_amd64.deb
rm -f bat_0.25.0_amd64.deb

# https://github.com/junegunn/fzf
curl -L https://github.com/junegunn/fzf/releases/download/v0.61.3/fzf-0.61.3-linux_amd64.tar.gz > fzf-0.61.3-linux_amd64.tar.gz
tar -xvzf fzf-0.61.3-linux_amd64.tar.gz
mv fzf ~/.local/bin/fzf
rm -f fzf-0.61.3-linux_amd64.tar.gz

#### SSH key doesn't seem to be valid at this point and the workspace gitconfig overrides to use SSH. Temporarily disable it so we can clone public git repos
mv ~/.gitconfig ~/.gitconfig.bak

#### Base-16
git clone http://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# Re-enable workspace gitconfig
mv ~/.gitconfig.bak ~/.gitconfig

# change default shell
sudo chsh -s /bin/fish bits

# https://github.com/jorgebucaran/fisher
# https://github.com/PatrickF1/fzf.fish
# https://github.com/jethrokuan/z
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source &&
	fisher install jorgebucaran/fisher &&
	fisher install PatrickF1/fzf.fish jethrokuan/z"

mkdir -p ~/.config/fish
ln -sf ~/.fish/config.fish ~/.config/fish/config.fish

#### Git
git config --global include.path "~/.gitconfig-ext"

#### Rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "Success"
