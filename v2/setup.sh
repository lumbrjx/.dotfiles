#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install -y $(cat installed-packages.txt)

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone your dotfiles repository
DOTFILES_REPO="https://github.com/yourusername/yourdotfilesrepo.git"
git clone $DOTFILES_REPO ~/.dotfiles

# Create symlinks for dotfiles
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/.config ~/.config

# Set up Neovim (if you use it)
mkdir -p ~/.config/nvim
ln -sf ~/.dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/.dotfiles/.config/nvim/lua ~/.config/nvim/lua

# Install Neovim plugins (if you use Packer)
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Set Zsh as the default shell
chsh -s $(which zsh)

echo "Setup complete! Please restart your terminal."
