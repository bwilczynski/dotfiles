# Dotfiles

Dotfiles for macOS and for [Omarchy](https://omarchy.org/) Linux, managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repo is organized into one
stow package per tool, so each machine installs only what it needs.

## Packages

| Package    | Installs                                        | Platform |
| ---------- | ----------------------------------------------- | -------- |
| `git`      | `.gitconfig` (commit identity)                  | both     |
| `zsh`      | `.zshrc`, `.fzf.zsh`, `.kubectl.zsh`            | macOS    |
| `tmux`     | `.tmux.conf`                                    | macOS    |
| `nvim`     | `.config/nvim/` (LazyVim)                       | macOS    |
| `ghostty`  | `.config/ghostty/`                              | macOS    |
| `starship` | `.config/starship.toml`                         | macOS    |
| `jj`       | `.config/jj/`                                   | macOS    |
| `herdr`    | `.config/herdr/`                                | macOS    |
| `lazygit`  | `Library/Application Support/lazygit/`          | macOS    |
| `claude`   | `.claude/` settings and themes                  | macOS    |
| `macos`    | `.config/macos/` and the keyremap LaunchAgent   | macOS    |
| `mise`     | `.config/mise/config.toml`                      | Linux    |
| `omarchy`  | Hyprland and Omarchy overrides, `.XCompose`     | Linux    |

The macOS-only rows are not a portability limitation. Omarchy ships its own
configuration for tmux, ghostty, starship, lazygit, herdr, and Neovim, and
re-renders several of them on `omarchy theme set`; stowing the statically themed
macOS versions over them would break theme switching and Omarchy's menus. See
"Omarchy" below.

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
stow git zsh tmux nvim starship            # minimal / remote box
stow git zsh tmux nvim ghostty starship \
     jj herdr lazygit claude macos         # full macOS workstation
```

Preview before committing to it with `stow -n -v <package>`, and remove a
package with `stow -D <package>`.

Start tmux and press `prefix + I` to install plugins.

If `~/.gitconfig` already exists on the machine, `stow git` will report a
conflict. Merge the existing file into `git/.gitconfig` by hand first; stow will
not overwrite it.

## Installation — Omarchy

Stow is not part of the Omarchy base install:

```sh
omarchy pkg add stow
```

Omarchy installs and updates almost everything else itself, so only three
packages apply:

```sh
stow git mise omarchy
```

Then install the system half of the hibernation fix, which stow cannot place
because it lives outside `$HOME`:

```sh
sudo ~/.config/omarchy/no-hibernate.sh install
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
- `.config/omarchy/no-hibernate.sh` — run by hand, not by stow. Installs
  `/etc/systemd/sleep.conf.d/99-no-hibernate-t2.conf`, which is what actually
  blocks S4 on this Apple T2 machine; the menu entry above only hides the row.
  The file it writes carries the full diagnosis.

Because these are symlinks, `omarchy refresh config` and update migrations write
through them into this repository. That is deliberate: a migration that replaces
the keyboard layout shows up in `git status` instead of disappearing silently.
