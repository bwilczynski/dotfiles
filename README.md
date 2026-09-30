# Dotfiles

Dotfiles for macOS and for [Omarchy](https://omarchy.org/) Linux, managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repo is organized into one
stow package per tool, so each machine installs only what it needs.

## Packages

| Package    | Installs                                               | Platform |
| ---------- | ------------------------------------------------------ | -------- |
| `git`      | `.gitconfig`, `.config/git/ignore`                     | both     |
| `zsh`      | `.zprofile`, `.zshrc`, `.fzf.zsh`                      | macOS    |
| `tmux`     | `.tmux.conf`                                           | macOS    |
| `nvim`     | `.config/nvim/` (LazyVim)                              | macOS    |
| `ghostty`  | `.config/ghostty/`                                     | macOS    |
| `starship` | `.config/starship.toml`                                | macOS    |
| `jj`       | `.config/jj/`                                          | macOS    |
| `herdr`    | `.config/herdr/`                                       | macOS    |
| `bat`      | `.config/bat/config`                                   | macOS    |
| `claude`   | `.claude/` settings and instructions                   | both     |
| `codex`    | `.codex/AGENTS.md` (agent instructions)                | both     |
| `mise`     | `.config/mise/config.toml` (global tool list)          | both     |
| `theme`    | `.config/theme/`, Claude's theme, `theme-set`          | macOS    |
| `macos`    | `.config/macos/` and the keyremap LaunchAgent          | macOS    |
| `omarchy`  | Hyprland/Omarchy overrides, `.XCompose`, `.local/bin/` | Linux    |

The macOS-only rows are not a portability limitation. Omarchy ships its own
configuration for tmux, ghostty, starship, herdr, and Neovim, and re-renders
several of them on `omarchy theme set`; stowing the macOS versions over them
would break theme switching and Omarchy's menus. See "Omarchy" below.

The `agents` package is the exception to the table: it holds the global agent
instructions that `claude` and `codex` both symlink to, and is never stowed
itself.

Everything else at the repo root — `Brewfile`, `Brewfile.optional`,
`README.md`, `CLAUDE.md`, `docs/` — is repo-only and never symlinked.

## Installation — macOS

Install the Homebrew dependencies:

```sh
brew bundle
```

`Brewfile` contains only the bootstrap requirements: stow, the shell's
dependencies, mise, and the terminal font. `Brewfile.optional` holds
everything else Homebrew owns on the workstation: the tools the tracked configs
use, general CLIs, and applications. Install it with:

```sh
brew bundle --file Brewfile.optional
```

Because the two files together list every package meant to be there, they also
prune whatever is not. Preview first, since the cleanup uninstalls:

```sh
cat Brewfile Brewfile.optional | brew bundle cleanup --file=-          # dry run
cat Brewfile Brewfile.optional | brew bundle cleanup --file=- --force
```

Neither Brewfile carries the coding agents or language runtimes. Claude Code
and Codex cut releases far more often than their Homebrew casks follow, and a
runtime in Homebrew is a second copy beside the one a project pins, so the
`mise` package owns both:

```sh
stow --no-folding mise
mise install
```

`mise/.config/mise/config.toml` is the global tool list — the coding agents
(Claude Code, Codex, opencode), Node, Python, Go, and CLIs such as `gh` and
hunk installed from registries or release binaries. Tools a single project
needs belong in that project's own `mise.toml`. `.zshrc` activates mise only
when the binary is on `PATH`, so a machine without it is unaffected. Upgrade
with `mise up`. Claude
Code's own auto-updater is off (`autoUpdates: false` in
`claude/.claude/settings.json`) so the running binary cannot drift away from the
version mise installed.

Stow the packages you want. The repo lives at `~/.dotfiles`, so stow's default
target is `$HOME` and no `-t` flag is needed:

```sh
stow git zsh tmux nvim starship            # minimal / remote box
stow git zsh tmux nvim ghostty starship jj \
     herdr bat                             # full macOS workstation, plus:
stow --no-folding claude codex mise theme macos  # directories shared with other writers
```

Preview before committing to it with `stow -n -v <package>`, and remove a
package with `stow -D <package>`.

### Switching themes

`theme/.config/theme/current` is a tracked symlink to one of the theme
directories under `theme/`. `theme-set`, installed into `~/.local/bin` by the
`theme` package, repoints it; commit the change afterwards to keep it:

```sh
theme-set                # list the themes, marking the current one
theme-set tokyo-night    # switch
```

Restart ghostty and Neovim to pick up the new palette. A Claude Code session
already running will not retint until it is restarted either — its theme is
reached through a symlink inside the repo rather than through a watched
`~/.config` directory, so it has no way to notice the change while running.

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
| Move window or tab left / right | `prefix+Ctrl+p` / `prefix+Ctrl+n` |
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

Global ignore patterns live in `git/.config/git/ignore`, the path git reads
by default. Do not set `core.excludesfile` in `~/.gitconfig.local`: it replaces
that file instead of adding to it, silently dropping every tracked pattern. A
pre-existing `~/.config/git/ignore` makes `stow git` conflict; fold its
patterns into the tracked file and delete it first.

## Installation — Omarchy

Stow is not part of the Omarchy base install:

```sh
omarchy pkg add stow
```

Omarchy installs and updates almost everything else itself, so only these
packages apply:

```sh
stow --no-folding git claude codex mise omarchy
```

`claude` carries no theme: Omarchy generates `~/.claude/themes/omarchy.json` on
every `omarchy theme set`, and the tracked `settings.json` already selects it
as `custom:omarchy` — the name macOS uses for its own theme too, so the shared
setting is right on both. Avoid `omarchy-theme-set-claude --activate`: it
rewrites `settings.json` with `mv`, which replaces the stow symlink with a
plain file. If `ls -l ~/.claude/settings.json` ever shows one, delete it and
re-run `stow --no-folding claude`.

`--no-folding` is required on Linux and is not optional. Without it, stow
symlinks a whole *directory* whenever the target does not already exist — on a
fresh machine that makes `~/.config` itself a symlink into this repo, and every
file Omarchy writes there afterwards (`omarchy/shell.json`, the active theme
symlink, `current/`) lands in `git status`. Most macOS packages do not need the
flag because each of them owns its directory outright; the exceptions are the
ones that share a directory with another writer: `claude`, `codex`, and `mise`,
whose tools write there; `theme`, which places files in `~/.claude/themes` and
`~/.local/bin`; and `macos`, whose LaunchAgent sits in `~/Library/LaunchAgents`
beside other apps' agents.

Then install the system half of the hibernation fix, which stow cannot place
because it lives outside `$HOME`:

```sh
sudo omarchy-no-hibernate install
```

Dictation is not tracked here; restore it with `omarchy-voxtype-install`.

## macOS system settings

Stow does not apply system settings. Run `~/.config/macos/defaults.sh` by hand
after stowing the `macos` package. `keyremap.sh` is run for you: the package
also installs the `com.bwilczynski.keyremap` LaunchAgent, which runs it at every
login so the remapping survives reboots.

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
