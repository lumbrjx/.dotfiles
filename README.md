# dotfiles (chezmoi)

Managed with [chezmoi](https://chezmoi.io). Single source of truth for laptop + desktop.

## Host model
Each machine sets `host = "laptop"` or `host = "desktop"` in its local
`~/.config/chezmoi/chezmoi.toml` (prompted once on `chezmoi init`).
Host-specific files are templates that `include` a raw fragment from `.fragments/`:

- hypr/hyprpaper.conf, hypr/hyprland.conf
- waybar/config.jsonc, waybar/toggle-waybar.sh

Everything else is shared verbatim across both machines.

## Daily use
    chezmoi edit ~/.config/hypr/hyprland.conf   # edit a managed file
    chezmoi add  ~/.config/foo                   # start managing a new file
    chezmoi diff                                 # preview changes vs live
    chezmoi apply                                # apply source -> live
    chezmoi update                               # git pull --rebase + apply  <-- the daily sync

## New machine
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
    chezmoi init --apply <REPO_URL>              # prompts for host, then applies

## Editing a host-specific file
The live file maps to a *.tmpl that includes .fragments/<name>.<host>.<ext>.
Edit the matching fragment in .fragments/, then `chezmoi apply`.
