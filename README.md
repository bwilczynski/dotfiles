# Dotfiles

## Installation

Install the shell dependencies:

```sh
brew install starship direnv fzf kubectl kustomize
```

Install [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager):

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Run stow to create symlinks:

```sh
stow .
```

Stow deploys `.config/starship.toml`; `.zshrc` initializes Starship automatically when it is installed.

Start tmux and press `prefix + I` to install plugins.
