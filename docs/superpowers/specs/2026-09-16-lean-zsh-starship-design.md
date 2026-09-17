# Lean Zsh and Starship Design

## Goal

Replace Oh My Zsh and Powerlevel10k with a direct Zsh configuration and a minimal, Catppuccin Mocha Starship prompt.

## Scope

- Remove Oh My Zsh and Powerlevel10k initialization from `.zshrc`.
- Preserve interactive completion, `direnv`, vi keybindings, editor selection, locale settings, fzf, kubectl, and the optional private `.zshrc.custom` file.
- Add `.config/starship.toml` as the tracked Starship configuration.
- Remove `.p10k.zsh` from the repository.
- Remove `.devbox.zsh` from the repository and stop sourcing it.
- Add Starship as a documented Homebrew prerequisite.

## Startup design

`.zshrc` will initialize Zsh completion with `compinit`, then a direct integration for direnv. It will no longer initialize autojump or source the devbox module. The fzf, kubectl, and private optional module sourcing remain unchanged. `eval "$(starship init zsh)"` will be the final startup action so Starship owns the prompt after all shell behavior is configured.

The configuration assumes Starship is installed through Homebrew. A command-existence guard will leave the shell usable if Starship is temporarily unavailable.

## Prompt design

Starship will use a compact two-line prompt with Catppuccin Mocha colors:

1. The information line displays the current directory and compact Git branch/status information. Long commands, active Python virtual environments, and SSH-only user/host context appear right-aligned.
2. The input line displays `❯` in insert mode and `❮` in normal vi-command mode; non-zero command status is red.

The prompt will not add a blank line and will not enable language, package, cloud, time, or decorative-icon modules. Command duration appears only after five seconds, matching the prior P10k threshold.

## Intentional removals and compatibility

The Oh My Zsh `git` alias collection and `gitignore` plugin helper are intentionally not replaced. Native `git` commands and Starship Git status remain available. Autojump and the Docker-based `devbox` function are intentionally removed because they are no longer used. The user can later request specific Git aliases if any prove important.

The repository will stop tracking P10k configuration. Any installed `~/.oh-my-zsh` or Powerlevel10k directory outside this repository remains untouched; optional manual cleanup will be provided only after successful verification.

## Validation

Validation is configuration-oriented rather than unit-test-oriented:

- `zsh -n .zshrc` verifies Zsh syntax.
- `starship config` validates the TOML configuration after installation.
- A non-interactive Zsh startup check confirms that startup completes without errors.
- An interactive shell check confirms Starship initializes and exposes the expected prompt modules.
