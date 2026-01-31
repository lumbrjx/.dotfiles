#!/bin/bash
set -e

echo "Starting full dev + Hyprland setup for Fedora 43..."

# ---------------------------
# Prompt to skip package installation
# ---------------------------
read -rp "Do you want to skip package installation and go straight to moving dotfiles? (y/N): " SKIP_INSTALL
SKIP_INSTALL=${SKIP_INSTALL:-N}

if [[ "$SKIP_INSTALL" != [yY] ]]; then
    # 1️⃣ Update system
    echo "Updating system..."
    sudo dnf update -y

    # 2️⃣ Install fonts if not already installed
    if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono Nerd Font Complete" ]; then
        echo "Installing JetBrains Mono Nerd Font..."
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        curl -fLo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
        unzip -o JetBrainsMono.zip
        rm JetBrainsMono.zip
        fc-cache -fv
    else
        echo "JetBrains Mono Nerd Font already installed, skipping..."
    fi

    # 3️⃣ Install Alacritty
    if ! command -v alacritty &>/dev/null; then
        echo "Installing Alacritty..."
        sudo dnf install -y alacritty --skip-broken
    else
        echo "Alacritty already installed, skipping..."
    fi

    # 4️⃣ Install Neovim
    if ! command -v nvim &>/dev/null; then
        echo "Installing Neovim..."
        sudo dnf install -y neovim --skip-broken
    else
        echo "Neovim already installed, skipping..."
    fi

    # 5️⃣ Install Hyprland from COPR or Fedora repo
    if ! command -v Hyprland &>/dev/null; then
        echo "Installing Hyprland..."
        sudo dnf install -y dnf-plugins-core --skip-broken
        if sudo dnf copr enable solopasha/hyprland -y; then
            sudo dnf install -y hyprland --skip-broken || sudo dnf install -y hyprland --skip-broken
        else
            sudo dnf install -y hyprland --skip-broken
        fi
    else
        echo "Hyprland already installed, skipping..."
    fi

    # 6️⃣ Hyprland essentials
    for pkg in waybar rofi-wayland wl-clipboard grim slurp mako xdg-desktop-portal-hyprland brightnessctl playerctl; do
        if ! rpm -q $pkg &>/dev/null; then
            echo "Installing $pkg..."
            sudo dnf install -y $pkg --skip-broken
        else
            echo "$pkg already installed, skipping..."
        fi
    done

    sudo dnf install -y polkit-gnome-1 --skip-broken || echo "polkit-gnome not available, skipping"

    # 7️⃣ tmux
    if ! command -v tmux &>/dev/null; then
        echo "Installing tmux..."
        sudo dnf install -y tmux --skip-broken
    else
        echo "tmux already installed, skipping..."
    fi

    # 8️⃣ zsh + Oh My Zsh
    if ! command -v zsh &>/dev/null; then
        echo "Installing zsh..."
        sudo dnf install -y zsh curl git --skip-broken
        export RUNZSH=no
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "zsh already installed, skipping..."
    fi

    # 9️⃣ zsh plugins
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
            sudo dnf install -y $plugin --skip-broken
        else
            echo "Plugin $plugin already installed, skipping..."
        fi
    done

    # 🔟 swaync + companions
    for pkg in swaync libnotify playerctl pamixer fzf zoxide; do
        if ! command -v $pkg &>/dev/null; then
            echo "Installing $pkg..."
            sudo dnf install -y $pkg --skip-broken
        else
            echo "$pkg already installed, skipping..."
        fi
    done

    # Rust
    if [ ! -f "$HOME/.cargo/env" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
    else
        echo "Rust already installed, skipping..."
    fi

    # Latest Go
    if ! command -v go &>/dev/null; then
        LATEST=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+(\.[0-9]+)?\.linux-amd64\.tar\.gz' | head -1)
        sudo rm -rf /usr/local/go
        wget https://go.dev/dl/$LATEST
        sudo tar -C /usr/local -xzf $LATEST
        if ! grep -q '/usr/local/go/bin' ~/.zshrc; then
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
        fi
        source ~/.zshrc
        go version
    else
        echo "Go already installed, skipping..."
    fi

    # Cleanup
    sudo dnf clean all
else
    echo "Skipping package installation as requested..."
fi

# ---------------------------
# Dotfiles deployment
# ---------------------------
echo "Setting up configuration files..."

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"

# Clone repo if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/lumbrjx/.dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
git fetch --all
git checkout latest

echo "Backing up existing configs to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

declare -A config_paths=(
    ["alacritty"]="$HOME/.config/alacritty"
    ["hypr"]="$HOME/.config/hypr"
    ["nvim"]="$HOME/.config/nvim"
    ["polybar"]="$HOME/.config/polybar"
    ["rofii"]="$HOME/.config/rofi"
    ["swaync"]="$HOME/.config/swaync"
    ["waybar"]="$HOME/.config/waybar"
)

# Copy directories
for src in "${!config_paths[@]}"; do
    dest="${config_paths[$src]}"
    if [ -d "$dest" ]; then
        echo "Backing up existing $dest..."
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi
    echo "Deploying $src configuration..."
    mkdir -p "$dest"
    cp -r ".config/$src/"* "$dest/"
done

# Copy individual files
for file in .tmux.conf .zshrc; do
    if [ -f "$HOME/$file" ]; then
        echo "Backing up existing $file..."
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
    echo "Deploying $file..."
    cp -f "$file" "$HOME/"
done

# Make scripts executable
echo "Setting executable permissions for scripts..."
chmod +x "$DOTFILES_DIR"/scripts/*.sh
[ -f "$HOME/.config/waybar/toggle-waybar.sh" ] && chmod +x "$HOME/.config/waybar/toggle-waybar.sh"
[ -d "$HOME/.config/polybar" ] && chmod +x "$HOME/.config/polybar/"*.sh
[ -d "$HOME/.config/rofi" ] && chmod +x "$HOME/.config/rofi/"*.sh || true

echo "Configuration deployed successfully!"
echo "All done! Backups of old configs are in $BACKUP_DIR."
echo "Log out and back in for zsh as default shell."

