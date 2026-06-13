#!/bin/bash
set -e
trap 'gum log --level error "Script failed at line $LINENO: $BASH_COMMAND"' ERR

DOTFILES_DIR="$HOME/.dotfiles"
BACKUPS_BASE="$DOTFILES_DIR/backups"
BACKUP_DIR="$BACKUPS_BASE/restore_backup_$(date +%Y%m%d_%H%M%S)"

# Configs identical across machines -> shared/
SHARED_DIRS=(alacritty nvim rofi swaync)
# Configs that differ per machine -> <host>/
HOST_DIRS=(hypr waybar)

gum style \
    --foreground 212 --background 236 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "dotfiles restore"

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

cd "$DOTFILES_DIR"

# ---------------------------
# 1️⃣ Fetch and pick a version to restore
# ---------------------------
gum log --level info "Fetching tags..."
git fetch --tags --force

ORIGINAL_REF=$(git symbolic-ref --short -q HEAD || git rev-parse --short HEAD)
CHECKED_OUT=0

SOURCE=$(gum choose --header "Restore configs from which source?" \
    "latest tag" "specific version" "current checkout ($ORIGINAL_REF)")

case "$SOURCE" in
    "latest tag")
        gum log --level info "Checking out 'latest'..."
        git checkout --quiet latest
        CHECKED_OUT=1
        ;;
    "specific version")
        TAG=$(git tag --list "v*" | sort -V | gum choose --header "Pick a version")
        if [[ -z "$TAG" ]]; then
            gum log --level warn "No version selected. Aborting."
            exit 0
        fi
        gum log --level info "Checking out $TAG..."
        git checkout --quiet "$TAG"
        CHECKED_OUT=1
        ;;
    *)
        gum log --level info "Using current checkout ($ORIGINAL_REF)."
        ;;
esac

# Make sure we always return to where we started, even on failure.
restore_ref() {
    if [[ "$CHECKED_OUT" -eq 1 ]]; then
        git checkout --quiet "$ORIGINAL_REF" || true
        gum log --level info "Returned to $ORIGINAL_REF"
    fi
}
trap 'restore_ref' EXIT

# Build the list of (repo source -> local dest) pairs for this host.
declare -A config_paths=()
for d in "${SHARED_DIRS[@]}"; do config_paths["$HOME/.config/$d"]="shared/.config/$d"; done
for d in "${HOST_DIRS[@]}";   do config_paths["$HOME/.config/$d"]="$HOST/.config/$d"; done

# ---------------------------
# 2️⃣ Back up current LOCAL configs (so a bad restore is recoverable)
# ---------------------------
backup_local() {
    mkdir -p "$BACKUP_DIR/.config"
    for local_dir in "${!config_paths[@]}"; do
        if [ -d "$local_dir" ]; then
            cp -r "$local_dir" "$BACKUP_DIR/.config/"
        fi
    done
    if [ -f "$HOME/.tmux.conf" ]; then cp -f "$HOME/.tmux.conf" "$BACKUP_DIR/.tmux.conf"; fi
    if [ -f "$HOME/.zshrc" ];     then cp -f "$HOME/.zshrc"     "$BACKUP_DIR/.zshrc";     fi
}

gum spin --spinner dot --title "Backing up current local configs..." -- \
    bash -c "$(declare -p config_paths); BACKUP_DIR='$BACKUP_DIR'; $(declare -f backup_local); backup_local"
gum log --level info "Local backup saved to $BACKUP_DIR"

# ---------------------------
# 3️⃣ Confirm before overwriting the machine
# ---------------------------
if ! gum confirm "Overwrite local configs with repo versions ($HOST)?"; then
    gum log --level warn "Aborted. Nothing on your machine was changed."
    exit 0
fi

# ---------------------------
# 4️⃣ Copy repo configs onto the machine
# ---------------------------
for local_dir in "${!config_paths[@]}"; do
    src="$DOTFILES_DIR/${config_paths[$local_dir]}"
    if [[ ! -d "$src" ]]; then
        gum log --level warn "Missing in repo, skipping: ${config_paths[$local_dir]}"
        continue
    fi
    mkdir -p "$local_dir"
    err_file=$(mktemp)
    rc=0
    gum spin --spinner dot --title "Restoring $(basename "$local_dir")..." -- \
        bash -c "rsync -a \"$src/\" \"$local_dir/\" 2>'$err_file'" || rc=$?
    if [[ $rc -eq 0 ]]; then
        gum log --level info "Restored $local_dir"
    else
        gum log --level warn "rsync for $(basename "$local_dir") exited $rc (continuing)"
        [ -s "$err_file" ] && gum log --level warn "$(cat "$err_file")"
    fi
    rm -f "$err_file"
done

gum spin --spinner dot --title "Restoring dotfiles..." -- bash -c "
    if [ -f '$DOTFILES_DIR/shared/.tmux.conf' ]; then cp -f '$DOTFILES_DIR/shared/.tmux.conf' \"\$HOME/.tmux.conf\"; fi
    if [ -f '$DOTFILES_DIR/shared/.zshrc' ];     then cp -f '$DOTFILES_DIR/shared/.zshrc'     \"\$HOME/.zshrc\";     fi
"
gum log --level info "Restored .tmux.conf and .zshrc"

gum style --foreground 82 --bold "All done! Configs restored ($HOST) from ${SOURCE}. Backup at $BACKUP_DIR"
