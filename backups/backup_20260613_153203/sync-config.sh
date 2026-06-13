#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUPS_BASE="$DOTFILES_DIR/backups"
BACKUP_DIR="$BACKUPS_BASE/backup_$(date +%Y%m%d_%H%M%S)"

# Configs identical across machines -> shared/
SHARED_DIRS=(alacritty nvim rofi swaync)
# Configs that differ per machine -> <host>/
HOST_DIRS=(hypr waybar)

gum style \
    --foreground 212 --background 236 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "dotfiles sync"

# ---------------------------
# Host detection (desktop/laptop)
# ---------------------------
detect_host() {
    local marker="$HOME/.config/dotfiles-host"
    if [[ -f "$marker" ]]; then
        cat "$marker"
        return
    fi
    local choice
    choice=$(gum choose --header "Which machine is this?" "desktop" "laptop")
    [[ -z "$choice" ]] && { gum log --level error "No host selected. Aborting." >&2; exit 1; }
    mkdir -p "$(dirname "$marker")"
    echo "$choice" >"$marker"
    echo "$choice"
}

HOST=$(detect_host)
gum log --level info "Host: $HOST"

# ---------------------------
# 1️⃣ Backup current repo state
# ---------------------------
gum spin --spinner dot --title "Backing up current .dotfiles..." -- bash -c "
    mkdir -p '$BACKUP_DIR'
    find '$DOTFILES_DIR' -maxdepth 1 -mindepth 1 ! -name 'backups' ! -name '.git' -exec cp -r {} '$BACKUP_DIR/' \;
"
gum log --level info "Backup saved to $BACKUP_DIR"

# ---------------------------
# 2️⃣ Copy local configs into repo
# ---------------------------
sync_dir() {  # $1 = ~/.config subdir, $2 = repo dest dir
    local src="$HOME/.config/$1"
    local dest="$DOTFILES_DIR/$2/.config/$1"
    [[ -d "$src" ]] || { gum log --level warn "Missing locally, skipping: $1"; return; }
    mkdir -p "$dest"
    gum spin --spinner dot --title "Syncing $1 -> $2..." -- rsync -a --delete "$src/" "$dest/"
    gum log --level info "Synced $1 -> $2/"
}

for d in "${SHARED_DIRS[@]}"; do sync_dir "$d" "shared"; done
for d in "${HOST_DIRS[@]}";   do sync_dir "$d" "$HOST"; done

gum spin --spinner dot --title "Syncing dotfiles..." -- bash -c "
    cp -f ~/.tmux.conf '$DOTFILES_DIR/shared/.tmux.conf'
    cp -f ~/.zshrc     '$DOTFILES_DIR/shared/.zshrc'
"
gum log --level info "Synced .tmux.conf and .zshrc -> shared/"

# ---------------------------
# 3️⃣ Commit?
# ---------------------------
if ! gum confirm "Create a new commit?"; then
    gum log --level warn "Changes copied to .dotfiles but not committed."
    exit 0
fi

cd "$DOTFILES_DIR"

gum spin --spinner dot --title "Fetching tags..." -- git fetch --tags

LATEST_TAG=$(git tag --list "v*" | sort -V | tail -n1)

if [[ $LATEST_TAG =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
else
    MAJOR=0; MINOR=0; PATCH=0
fi

BUMP=$(gum choose --header "Version bump type? (current: ${LATEST_TAG:-none})" "patch" "minor" "major")

case "$BUMP" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_TAG="v$MAJOR.$MINOR.$PATCH"
gum log --level info "New version: $NEW_TAG"

COMMIT_MSG=$(gum input --placeholder "Commit message" --value "Update configs ($HOST) — $NEW_TAG")

# ---------------------------
# 4️⃣ Commit and push
# ---------------------------
gum spin --spinner dot --title "Committing and pushing..." -- bash -c "
    git add .
    git commit -m '$COMMIT_MSG'
    git tag '$NEW_TAG'
    git push origin main --tags
"
gum log --level info "Pushed $NEW_TAG to origin/main"

# ---------------------------
# 5️⃣ Update 'latest' tag?
# ---------------------------
if gum confirm "Point 'latest' tag to $NEW_TAG?"; then
    gum spin --spinner dot --title "Updating latest tag..." -- bash -c "
        git tag -f latest '$NEW_TAG'
        git push origin latest --force
    "
    gum log --level info "'latest' updated to $NEW_TAG"
else
    gum log --level warn "'latest' tag left untouched."
fi

gum style --foreground 82 --bold "All done! Configs synced ($HOST) and tagged as $NEW_TAG"
