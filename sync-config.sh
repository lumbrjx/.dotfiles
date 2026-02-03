#!/bin/bash
set -e

echo "Saving local configs back to .dotfiles repository..."

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$DOTFILES_DIR/backups_$(date +%Y%m%d_%H%M%S)"

# ---------------------------
# 1️⃣ Make backup of current repo
# ---------------------------
echo "🛡 Backing up current .dotfiles to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
find "$DOTFILES_DIR" -maxdepth 1 -mindepth 1 ! -name 'backups_*' -exec cp -r {} "$BACKUP_DIR/" \;
# ---------------------------
# 2️⃣ Copy local configs into repo
# ---------------------------
declare -A config_paths=(
    ["$HOME/.config/alacritty"]=".config/alacritty"
    ["$HOME/.config/hypr"]=".config/hypr"
    ["$HOME/.config/nvim"]=".config/nvim"
    ["$HOME/.config/rofi"]=".config/rofi"
    ["$HOME/.config/swaync"]=".config/swaync"
    ["$HOME/.config/waybar"]=".config/waybar"
)

for src in "${!config_paths[@]}"; do
    dest="$DOTFILES_DIR/${config_paths[$src]}"
    mkdir -p "$dest"
    echo "📂 Copying from $src -> $dest"
    rsync -av --delete "$src/" "$dest/"
done

# Single files
cp -f ~/.tmux.conf "$DOTFILES_DIR/.tmux.conf"
cp -f ~/.zshrc "$DOTFILES_DIR/.zshrc"

read -rp "Do you want to create a new commit? (y/N): " COMMIT_CHANGES
COMMIT_CHANGES=${COMMIT_CHANGES:-N}
if [[ ! "$COMMIT_CHANGES" =~ [yY] ]]; then
    echo "Changes copied to .dotfiles but not committed."
    exit 0
fi
# ---------------------------
# 3️⃣ Fetch tags and determine new version
# ---------------------------
cd "$DOTFILES_DIR"
git fetch --tags

# Find latest vX.X.X tag
LATEST_TAG=$(git tag --list "v*" | sort -V | tail -n1)

# Parse numbers
if [[ $LATEST_TAG =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
else
    MAJOR=0
    MINOR=0
    PATCH=0
fi

# Bump patch
PATCH=$((PATCH + 1))
NEW_TAG="v$MAJOR.$MINOR.$PATCH"

echo "Latest tag: $LATEST_TAG"
echo "Bumping to new tag: $NEW_TAG"

# ---------------------------
# 4️⃣ Commit changes
# ---------------------------
git add .
git commit -m "Update configs and bump version to $NEW_TAG"
git tag "$NEW_TAG"
git push origin main --tags

# ---------------------------
# 5️⃣ Ask if latest should point to this new tag
# ---------------------------
read -rp "Do you want the 'latest' tag to point to $NEW_TAG? (y/N): " UPDATE_LATEST
UPDATE_LATEST=${UPDATE_LATEST:-N}

if [[ "$UPDATE_LATEST" =~ [yY] ]]; then
    git tag -f latest "$NEW_TAG"
    git push origin latest --force
    echo "'latest' tag updated to $NEW_TAG"
else
    echo "'latest' tag left untouched."
fi

echo "All configs saved, committed, and tagged!"

