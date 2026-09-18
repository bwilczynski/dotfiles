# Dotfiles

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

Run stow to create symlinks:

```sh
stow .
```

Stow deploys `.config/starship.toml`; `.zshrc` initializes Starship automatically when it is installed.

Start tmux and press `prefix + I` to install plugins.
