# Dotfiles with chezmoi — setup & daily guide

This repo (branch `chezmoi`) is the single source of truth for **laptop** and **desktop**,
managed with [chezmoi](https://chezmoi.io). It replaces the old `~/.dotfiles` push/pull
scripts. The old `~/.dotfiles` repo and its `main` branch are kept untouched as a fallback.

---

## Mental model (read this once)

There are **two copies** of every config:

- **Source** (the truth): `~/.local/share/chezmoi/…` — a git repo.
- **Live** (generated): `~/.config/…`, `~/.zshrc`, etc.

You change the **source**, then `chezmoi apply` writes it to the live files.
Commit + push so the other machine can `chezmoi update` to pull + apply.

```
   SOURCE  ──chezmoi apply──►  LIVE files in $HOME
   (git)                       (what your apps read)
     ▲                              │
     └────── chezmoi re-add ────────┘   (capture a live edit back into source)
```

> ⚠️ **Never run `chezmoi` with `sudo`.** It manages *your* user dotfiles. `sudo chezmoi`
> looks in `/root/.local/share/chezmoi` and fails. Always run it as yourself.

---

## Desktop first-time setup

```bash
# 1. install chezmoi (user-local, no sudo)
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. pull the chezmoi branch — when it asks "Which machine is this", type:  desktop
~/.local/bin/chezmoi init --branch chezmoi git@github.com:lumbrjx/.dotfiles.git

# 3. preview what would change (read it!)
~/.local/bin/chezmoi diff
```

### If `chezmoi apply` says "permission denied"
That means some files under `~/.config` are owned by **root** (usually from an old
`sudo cp`). Fix ownership of your own home, then apply *without* sudo:

```bash
# see what's root-owned
find ~/.config ~/.local/share/applications ~/.zshrc ~/.tmux.conf ! -user "$USER" -ls 2>/dev/null

# hand it back to yourself
sudo chown -R "$USER:$USER" ~/.config ~/.local/share/applications ~/.zshrc ~/.tmux.conf

# now apply as yourself
~/.local/bin/chezmoi apply
~/.local/bin/chezmoi diff      # empty = fully in sync
```

### Add `~/.local/bin` to PATH
So you can type `chezmoi` instead of the full path. If it's not already in your
`~/.zshrc`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Daily workflow

### Sync (the important one — replaces the old scripts)
```bash
chezmoi update      # = git pull --rebase + apply. Run on each machine to stay in sync.
```
Because it's a real git pull/rebase, two machines diverging shows up as a **merge**,
not a silent overwrite — that's why old updates can't "resurface" anymore.

### Edit an existing config
```bash
chezmoi edit ~/.config/hypr/hyprlock.conf   # edits the SOURCE
chezmoi diff
chezmoi apply
```
…or if you already hand-edited the **live** file:
```bash
chezmoi re-add ~/.config/hypr/hyprlock.conf  # pull live change back into source
```

### Add a brand-new config (shared across both machines)
```bash
chezmoi add ~/.config/newapp/config.toml
```

### Save & share any change
After editing/adding, always:
```bash
chezmoi git -- add -A
chezmoi git -- commit -m "describe the change"
chezmoi git -- push
```
(`chezmoi git -- …` runs git inside the source repo so you don't have to `cd` there.)

---

## Making one file differ per machine

The simple recipe — **the only one you need to remember**:

```bash
chezmoi chattr +template ~/.config/foo/bar.conf   # 1. make it a template
chezmoi edit ~/.config/foo/bar.conf               # 2. add the if/else
chezmoi apply                                      # 3. apply
```

In step 2, wrap the parts that differ:

```
{{ if eq .host "laptop" }}
monitor = eDP-1, 1920x1080, 0x0, 1
{{ else }}
monitor = HDMI-A-3, 2560x1440, 0x0, 1
{{ end }}
```

`.host` is automatically `"laptop"` or `"desktop"` on each machine.

### Edge case (you'll rarely hit this)
If a file's **contents** already contain literal `{{ }}` (e.g. `waybar/config.jsonc`
uses `{{artist}}`), the template engine chokes. Those files use a different pattern:
a `*.tmpl` that picks a raw file from `.fragments/` via `include`. The four files set
up that way already are:

- `dot_config/hypr/executable_hyprpaper.conf.tmpl`
- `dot_config/hypr/executable_hyprland.conf.tmpl`
- `dot_config/waybar/executable_config.jsonc.tmpl`
- `dot_config/waybar/executable_toggle-waybar.sh.tmpl`

To edit one of those per-host, edit the matching fragment in
`~/.local/share/chezmoi/.fragments/<name>.<host>.<ext>` then `chezmoi apply`.
If you ever hit a *new* file with this problem, `chezmoi apply` errors with
`function "x" not defined` — that's the signal to convert it to the fragment pattern.

---

## Layout reference

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # prompts "laptop/desktop" once on init
├── .chezmoiignore              # cruft + these docs (never deployed to $HOME)
├── .fragments/                 # raw per-host file bodies (not deployed directly)
├── dot_zshrc                   # → ~/.zshrc
├── dot_tmux.conf               # → ~/.tmux.conf
├── dot_config/                 # → ~/.config/...
│   ├── alacritty/ nvim/ rofi/ swaync/   (shared)
│   ├── hypr/      (mix: shared + per-host templates)
│   └── waybar/    (mix: shared + per-host templates)
└── dot_local/share/applications/Alacritty.desktop
```

Naming: `dot_` → `.`, `executable_` → +x bit, `*.tmpl` → templated.

---

## Eventual cutover (later, when you trust it)

The `chezmoi` branch and the old `main` have **unrelated histories and incompatible
layouts**, so don't `git merge` them (it would pile both file trees together).
When you're confident on both machines, make chezmoi canonical deliberately:

```bash
# from the chezmoi source repo, once proven:
chezmoi git -- push origin chezmoi:main --force
```
…then delete the old `installer.sh` / `sync-config.sh` / `sync_to_machine.sh` scripts.
