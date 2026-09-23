# Dotfiles

Dotfiles for macOS and for [Omarchy](https://omarchy.org/) Linux, managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repo is organized into one
stow package per tool, so each machine installs only what it needs.

## Packages

| Package    | Installs                                        | Platform |
| ---------- | ----------------------------------------------- | -------- |
| `git`      | `.gitconfig` (identity and aliases)             | both     |
| `zsh`      | `.zshrc`, `.fzf.zsh`, `.kubectl.zsh`            | macOS    |
| `tmux`     | `.tmux.conf`                                    | macOS    |
| `nvim`     | `.config/nvim/` (LazyVim)                       | macOS    |
| `ghostty`  | `.config/ghostty/`                              | macOS    |
| `starship` | `.config/starship.toml`                         | macOS    |
| `jj`       | `.config/jj/`                                   | macOS    |
| `herdr`    | `.config/herdr/`                                | macOS    |
| `claude`   | `.claude/` settings and themes                  | macOS    |
| `theme`    | `.config/theme/` (palettes + `current` symlink) | macOS    |
| `macos`    | `.config/macos/` and the keyremap LaunchAgent   | macOS    |
| `mise`     | `.config/mise/config.toml`                      | Linux    |
| `omarchy`  | Hyprland/Omarchy overrides, `.XCompose`, `bin/` | Linux    |

The macOS-only rows are not a portability limitation. Omarchy ships its own
configuration for tmux, ghostty, starship, herdr, and Neovim, and re-renders
several of them on `omarchy theme set`; stowing the macOS versions over them
would break theme switching and Omarchy's menus. See "Omarchy" below.

Everything else at the repo root — `Brewfile`, `README.md`, `CLAUDE.md`,
`docs/` — is repo-only and never symlinked.

## Installation — macOS

Install the Homebrew dependencies:

```sh
brew bundle
```

`Brewfile` contains only the bootstrap requirements. To install the optional
tools configured in this repository, run:

```sh
brew bundle --file Brewfile.optional
```

`kubectx` also provides `kubens`.

Install [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager):

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Stow the packages you want. The repo lives at `~/.dotfiles`, so stow's default
target is `$HOME` and no flags are needed:

```sh
stow git zsh tmux nvim starship theme      # minimal / remote box
stow git zsh tmux nvim ghostty starship \
     jj herdr claude theme macos           # full macOS workstation
```

Preview before committing to it with `stow -n -v <package>`, and remove a
package with `stow -D <package>`.

Start tmux and press `prefix + I` to install plugins.

### tmux and Herdr keybindings

On macOS, tmux sessions map to Herdr workspaces, tmux windows to Herdr tabs,
and panes to panes. Both tools use `Ctrl+Space` as their prefix (`Ctrl+B` is
also a secondary tmux prefix).

| Action | Binding |
| ------ | ------- |
| Split top/bottom | `Option+Enter` or `prefix+h` |
| Split side-by-side | `Option+Shift+Enter` or `prefix+v` |
| Close pane | `Option+Escape` or `prefix+x` |
| Focus pane | `Ctrl+Option+arrows` |
| Resize pane | `Ctrl+Option+Shift+arrows` |
| Create / rename / close window or tab | `prefix+c` / `prefix+r` / `prefix+k` |
| Previous / next window or tab | `prefix+p` / `prefix+n` |
| Create / rename / close session or workspace | `prefix+Shift+c/r/k` |
| Previous / next session or workspace | `prefix+Shift+p/n` |

`prefix+1..9` always selects a window or tab. `Option+1..9` does the same
directly and coexists with Polish Option-letter input. It binds physical digit
keys, so if another layout ever makes it collide with symbol input, remove its
Ghostty, tmux, and Herdr entries together.

macOS deliberately keeps every Option-arrow chord for native word movement and
selection, so it does not copy Omarchy's direct Alt-arrow navigation. Ghostty
also keeps Option in native macOS mode, preserving Option-letter Polish
characters. Pane, window/tab, and session/workspace close actions do not ask
for confirmation, matching Omarchy. Omarchy continues to own its Linux configs
and dynamic theming; do not stow the macOS `tmux`, `herdr`, or `ghostty`
packages there.

### Git config layering

`git/.gitconfig` holds the commit identity and the aliases — everything that is
the same on every machine. It ends with an include of `~/.gitconfig.local`,
which is not tracked and is where machine-specific settings go: absolute paths,
credentials, per-host overrides. The include is last, so those values win. A
missing `~/.gitconfig.local` is not an error, so a fresh machine needs no setup.

This mirrors how `.zshrc` sources `~/.zshrc.custom`.

If `~/.gitconfig` already exists, `stow git` reports a conflict and **aborts the
entire command** — the other packages named alongside it are not stowed either.
Split the existing file first: the portable parts into `git/.gitconfig`, the
machine-specific ones into `~/.gitconfig.local`, then remove `~/.gitconfig` and
stow again.

Check for a stray `~/.config/git/config` too. Git reads it *before*
`~/.gitconfig`, so an identity left there is shadowed by the tracked one and
serves only to confuse; delete it once its contents are accounted for.

## Installation — Omarchy

Stow is not part of the Omarchy base install:

```sh
omarchy pkg add stow
```

Omarchy installs and updates almost everything else itself, so only three
packages apply:

```sh
stow --no-folding git mise omarchy
```

`--no-folding` is required on Linux and is not optional. Without it, stow
symlinks a whole *directory* whenever the target does not already exist — on a
fresh machine that makes `~/.config` itself a symlink into this repo, and every
file Omarchy writes there afterwards (`omarchy/shell.json`, the active theme
symlink, `current/`) lands in `git status`. The macOS packages do not need the
flag because each of them owns its directory outright; the `omarchy` package is
the only one that shares directories with a distribution that also writes to
them.

Then install the system half of the hibernation fix, which stow cannot place
because it lives outside `$HOME`:

```sh
sudo omarchy-no-hibernate install
```

Dictation is not tracked here; restore it with `omarchy-voxtype-install`.

## macOS system settings

`.config/macos/defaults.sh` and `keyremap.sh` are run by hand, not by stow.
Stowing the `macos` package installs the `com.bwilczynski.keyremap` LaunchAgent
that keeps the remapping applied across reboots.

## Omarchy

The `omarchy` package tracks only the files that differ from the templates
Omarchy ships in `/usr/share/omarchy/config`, so `omarchy update` keeps owning
everything else:

- `.config/hypr/input.lua` — Polish programmer layout, with Polish letters on
  AltGr. It repeats `kb_options` because the override replaces Omarchy's
  defaults wholesale rather than merging with them.
- `.config/hypr/monitors.lua` — monitor scale pinned to 1.6 instead of `auto`.
- `.config/omarchy/extensions/omarchy-menu.jsonc` — hides the Hibernate row.
- `.XCompose` — name and email compose sequences, on top of Omarchy's defaults.
- `.local/bin/omarchy-no-hibernate` — run by hand, not by stow. Installs
  `/etc/systemd/sleep.conf.d/99-no-hibernate-t2.conf`, which is what actually
  blocks S4 on this Apple T2 machine; the menu entry above only hides the row.
  The file it writes carries the full diagnosis.

Because these are symlinks, `omarchy refresh config` and update migrations write
through them into this repository. That is deliberate: a migration that replaces
the keyboard layout shows up in `git status` instead of disappearing silently.
