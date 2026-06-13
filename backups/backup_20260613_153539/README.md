# .dotfiles
## config
- distro : debian 12
- shell : zsh
- editor : neovim
- wm : i3wm
- fs : rofi
- bar : polybar
- terminal : alacritty
- DS : lightdm
- tmux


## v2 : Major change
- distro : fedora 42/43
- wm : hyperland
- bar : waybar
- DS : gnomedm

## Layout (desktop / laptop split)

```
shared/      configs identical on every machine (alacritty, nvim, rofi, swaync, .tmux.conf, .zshrc)
desktop/     per-host overrides for the desktop  (hypr + waybar — monitor HDMI-A-3)
laptop/      per-host overrides for the laptop   (hypr + waybar — monitor eDP-1, battery, touchpad)
```

Deploy order is **shared/ first, then the host overlay** on top.

The active host is stored in `~/.config/dotfiles-host` (`desktop` or `laptop`).
It's created automatically on first run; delete it to be re-prompted.

## Scripts

All scripts require [`gum`](https://github.com/charmbracelet/gum)
(`go install github.com/charmbracelet/gum@latest`), except `installer.sh`
which only needs it for the optional TUI prompts.

- `installer.sh`        — first-time bootstrap: install packages + deploy configs for this host
- `sync_to_machine.sh`  — pull repo configs onto this machine (restore, with version picker)
- `sync-config.sh`      — push this machine's live configs back into the repo, commit + tag

