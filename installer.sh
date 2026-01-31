#!/bin/bash
set -e

echo "Starting full dev + Hyprland setup for Fedora 43..."

# 1️⃣ Update system
sudo dnf update -y

# 2️⃣ Install fonts (JetBrains Mono Nerd Font)
echo "Installing JetBrains Mono Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
unzip -o JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv

# 3️⃣ Install Alacritty (once)
echo "Installing Alacritty..."
sudo dnf install -y alacritty --skip-broken

# 4️⃣ Install Neovim
echo "Installing Neovim..."
sudo dnf install -y neovim --skip-broken

# 5️⃣ Install Hyprland from COPR first
echo "Trying to install Hyprland from COPR..."
sudo dnf install -y dnf-plugins-core --skip-broken
if sudo dnf copr enable solopasha/hyprland -y; then
    echo "COPR enabled for Hyprland."
    sudo dnf install -y hyprland --skip-broken || { 
        echo "COPR install failed, falling back to DNF"; 
        sudo dnf install -y hyprland --skip-broken; 
    }
else
    echo "COPR not available, installing Hyprland from Fedora repo..."
    sudo dnf install -y hyprland --skip-broken
fi

# 6️⃣ Install Hyprland essentials
echo "Installing Hyprland essentials..."
sudo dnf install -y waybar rofi-wayland wl-clipboard grim slurp mako xdg-desktop-portal-hyprland brightnessctl playerctl --skip-broken

# Try polkit-gnome but skip if not available
sudo dnf install -y polkit-gnome-1 --skip-broken || echo "polkit-gnome not available, skipping"

# 7️⃣ Install tmux
echo "Installing tmux..."
sudo dnf install -y tmux --skip-broken

# 8️⃣ Install zsh + Oh My Zsh
echo "Installing zsh and Oh My Zsh..."
sudo dnf install -y zsh curl git --skip-broken
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 9️⃣ Install zsh plugins
echo "Installing zsh plugins..."
sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting --skip-broken

# 🔟 Install swaync + companions
echo "Installing swaync..."
sudo dnf install -y swaync libnotify playerctl pamixer --skip-broken
sudo dnf install fzf zoxide
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
# Get latest version
LATEST=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+(\.[0-9]+)?\.linux-amd64\.tar\.gz' | head -1)

# Remove old Go if exists
sudo rm -rf /usr/local/go

# Download and extract
wget https://go.dev/dl/$LATEST
sudo tar -C /usr/local -xzf $LATEST

# Add to PATH if not already in .zshrc
if ! grep -q '/usr/local/go/bin' ~/.zshrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
fi

# Reload shell
source ~/.zshrc

# Check version
go version

# 1️⃣1️⃣ Cleanup
sudo dnf clean all

echo "Settings up configuration"
git clone https://github.com/lumbrjx/.dotfiles.git
cd .dotfiles && git checkout latest

echo "Deploying configuration files..."

# Make sure config directories exist
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/hypr
mkdir -p ~/.config/nvim
mkdir -p ~/.config/polybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/swaync
mkdir -p ~/.config/waybar

# Copy Alacritty configs
echo "Copying Alacritty config..."
cp -r .config/alacritty/* ~/.config/alacritty/

# Copy Hyprland configs
echo "Copying Hyprland configs..."
cp -r .config/hypr/* ~/.config/hypr/

# Copy Neovim configs
echo "Copying Neovim config..."
cp -r .config/nvim/* ~/.config/nvim/

# Copy Polybar configs
echo "Copying Polybar config..."
cp -r .config/polybar/* ~/.config/polybar/

# Copy Rofi configs
echo "Copying Rofi config..."
cp -r .config/rofii/* ~/.config/rofi/

# Copy Swaync configs
echo "Copying Swaync config..."
cp -r .config/swaync/* ~/.config/swaync/

# Copy Waybar configs
echo "Copying Waybar config..."
cp -r .config/waybar/* ~/.config/waybar/

# Copy Tmux config
echo "Copying Tmux config..."
cp .tmux.conf ~/.tmux.conf

# Copy Zsh config
echo "Copying Zsh config..."
cp .zshrc ~/.zshrc

# Make scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh
chmod +x ~/.config/waybar/toggle-waybar.sh
chmod +x ~/.config/polybar/*.sh
chmod +x ~/.config/rofi/*.sh || true

echo "Configuration deployed successfully!"

echo "All packages installed successfully!"
echo "Remember to log out and back in for zsh as default shell."

