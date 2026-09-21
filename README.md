# Dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). The
repo is organized into one stow package per tool, so each machine installs only
what it needs.

## Packages

| Package    | Installs                                           |
| ---------- | -------------------------------------------------- |
| `zsh`      | `.zshrc`, `.fzf.zsh`, `.kubectl.zsh`               |
| `tmux`     | `.tmux.conf`                                       |
| `nvim`     | `.config/nvim/` (LazyVim)                          |
| `ghostty`  | `.config/ghostty/` (macOS)                         |
| `starship` | `.config/starship.toml`                            |
| `jj`       | `.config/jj/`                                      |
| `herdr`    | `.config/herdr/`                                   |
| `lazygit`  | `Library/Application Support/lazygit/` (macOS)     |
| `claude`   | `.claude/` settings and themes                     |
| `macos`    | `.config/macos/` and the keyremap LaunchAgent      |

Everything else at the repo root — `Brewfile`, `README.md`, `CLAUDE.md`,
`docs/` — is repo-only and never symlinked.

## Installation

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
stow zsh tmux nvim starship            # minimal / remote box
stow zsh tmux nvim ghostty starship \
     jj herdr lazygit claude macos     # full macOS workstation
```

Preview before committing to it with `stow -n -v <package>`, and remove a
package with `stow -D <package>`.

Start tmux and press `prefix + I` to install plugins.

## macOS system settings

`.config/macos/defaults.sh` and `keyremap.sh` are run by hand, not by stow.
Stowing the `macos` package installs the `com.bwilczynski.keyremap` LaunchAgent
that keeps the remapping applied across reboots.
