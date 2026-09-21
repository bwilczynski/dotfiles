# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/), organized as **one stow package per tool**. Each top-level package directory contains a home-relative tree; `stow <package>` symlinks it into `$HOME`. Because the repo lives at `~/.dotfiles`, stow's default target is already `$HOME`, so no `-t` flag is needed. `.stowrc` only ignores `.DS_Store`.

Files at the repo root (`Brewfile`, `Brewfile.optional`, `README.md`, `CLAUDE.md`, `docs/`) sit outside every package and are never symlinked.

## Deployment

```sh
stow zsh tmux nvim starship        # install a subset
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

## Conventions

- Adding a new tool means creating a new top-level package directory, not dropping files into an existing one.
- **Catppuccin Mocha** is the consistent theme across tmux, fzf, ghostty, lazygit, jj, and neovim.
