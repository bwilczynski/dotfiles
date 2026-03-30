# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/). Running `stow .` from the repo root creates symlinks in the home directory (`$HOME`) for all dotfiles. The `.stowrc` file excludes itself and `.DS_Store` from symlinking.

## Deployment

```sh
stow .
```

This symlinks all top-level dotfiles/directories (except ignored patterns) into `$HOME`.

## Structure

- **Shell (zsh):** `.zshrc` uses Oh My Zsh with Powerlevel10k theme, vi keybindings, and sources optional modules (`.fzf.zsh`, `.devbox.zsh`, `.kubectl.zsh`, `.zshrc.custom`)
- **Editor (neovim):** `.config/nvim/` is a LazyVim setup — plugins go in `lua/plugins/`, config in `lua/config/`
- **Terminal (Ghostty):** `.config/ghostty/config`
- **Tmux:** `.tmux.conf` with Catppuccin Mocha theme (plugin loaded from `~/.config/tmux/plugins/catppuccin/`)
- **Hammerspoon:** `.hammerspoon/` provides app launcher hotkeys via hyper key (ctrl+alt+cmd+shift)
- **Devbox:** `.devbox.zsh` defines a `devbox` function that runs a Docker-based dev environment
- **Catppuccin Mocha** is the consistent theme across tmux, fzf, ghostty, and neovim
