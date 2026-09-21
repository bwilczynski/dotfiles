# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform dotfiles repository for macOS and [Omarchy](https://omarchy.org/) Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/), organized as **one stow package per tool**. Each top-level package directory contains a home-relative tree; `stow <package>` symlinks it into `$HOME`. Because the repo lives at `~/.dotfiles`, stow's default target is already `$HOME`, so no `-t` flag is needed. `.stowrc` only ignores `.DS_Store`.

Files at the repo root (`Brewfile`, `Brewfile.optional`, `README.md`, `CLAUDE.md`, `docs/`) sit outside every package and are never symlinked.

## Deployment

```sh
stow git zsh tmux nvim starship    # install a subset (macOS)
stow git mise omarchy              # everything that applies on Omarchy
stow -n -v nvim                    # dry run
stow -D ghostty                    # uninstall a package
```

## Packages

- **`zsh`** — `.zshrc` (Oh My Zsh, Starship prompt, vi keybindings) plus the optional modules it sources: `.fzf.zsh`, `.kubectl.zsh`, and `.zshrc.custom` (not in this repo, machine-local)
- **`tmux`** — `.tmux.conf` with Catppuccin Mocha (plugin loaded from `~/.config/tmux/plugins/catppuccin/`)
- **`nvim`** — `.config/nvim/`, a LazyVim setup: plugins in `lua/plugins/`, config in `lua/config/`
- **`ghostty`** — `.config/ghostty/config` (macOS only)
- **`starship`** — `.config/starship.toml`
- **`jj`** — `.config/jj/config.toml`
- **`herdr`** — `.config/herdr/config.toml`
- **`lazygit`** — `Library/Application Support/lazygit/` (macOS path)
- **`claude`** — `.claude/settings.json` and themes
- **`macos`** — `.config/macos/defaults.sh` (system preferences, run by hand) and `keyremap.sh` (Caps Lock → Escape, Right Command → Right Option, built-in keyboard only), kept applied by the `com.bwilczynski.keyremap` LaunchAgent that this package installs
- **`git`** — `.gitconfig`: commit identity and aliases, plus a trailing include of
  `~/.gitconfig.local` for machine-specific settings (untracked, wins over the
  tracked values, absence is not an error); cross-platform
- **`mise`** — `.config/mise/config.toml`; Linux
- **`omarchy`** — Hyprland and Omarchy overrides plus `.XCompose`, and `.config/omarchy/no-hibernate.sh` (run by hand); Linux

Everything else is macOS-only. `zsh`, `tmux`, `ghostty`, `starship`, `jj`, `herdr`, `lazygit`, `nvim`, and `claude` are **not** stowed on Omarchy — see the conventions below.

## Conventions

- Adding a new tool means creating a new top-level package directory, not dropping files into an existing one.
- **Catppuccin Mocha** is the consistent theme across tmux, fzf, ghostty, lazygit, jj, and neovim — on macOS. On Omarchy the theme is whatever `omarchy theme set` selects, and the repo does not fight it.
- **Track deltas, not distro config.** Omarchy ships user-facing templates in `/usr/share/omarchy/config`, copies them into `~/.config`, keeps them current through `omarchy update` migrations, and re-renders several on `omarchy theme set`. The `omarchy` package tracks only files whose content differs from those templates. Before adding a Linux file, diff it against `/usr/share/omarchy/config/<path>`; if it matches, it does not belong here.
- Omarchy's own configs for tmux, ghostty, starship, lazygit, herdr, and neovim are theme-dynamic and menu-integrated. Do not stow the macOS packages over them.
- **Machine-local settings go in an untracked tail file**, sourced or included last so it wins: `zsh/.zshrc` sources `~/.zshrc.custom`, `git/.gitconfig` includes `~/.gitconfig.local`. Absolute paths and credentials belong there, never in a tracked file.
- Files outside `$HOME` cannot be stowed. Install them from a hand-run script in the owning package, as `macos/.config/macos/defaults.sh` and `omarchy/.config/omarchy/no-hibernate.sh` do.
